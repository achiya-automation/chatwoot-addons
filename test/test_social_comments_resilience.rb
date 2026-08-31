# frozen_string_literal: true

require 'json'
require 'logger'
require 'minitest/autorun'
require 'net/http'
require 'openssl'
require 'stringio'
require 'time'
require 'uri'

# Minimal Active Support compatibility for loading the initializer with the
# system Ruby.  Production loads the real implementations from Rails.
class Object
  def blank?
    respond_to?(:empty?) ? !!empty? : !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end
end

class NilClass
  def blank?
    true
  end
end

module ActiveRecord
  class RecordNotFound < StandardError; end
  class RecordNotUnique < StandardError; end
  class InvalidForeignKey < StandardError; end
end

module ActiveSupport
  module SecurityUtils
    module_function

    def secure_compare(left, right)
      left == right
    end
  end
end

class TestMiddlewareStack
  attr_reader :entries

  def initialize
    @entries = []
  end

  def use(entry)
    entries << entry
  end
end

class TestApplicationConfig
  attr_reader :middleware

  def initialize
    @middleware = TestMiddlewareStack.new
  end
end

class TestApplication
  attr_reader :config

  def initialize
    @config = TestApplicationConfig.new
  end
end

module Rails
  module_function

  def application
    @application ||= TestApplication.new
  end

  def logger
    @logger ||= Logger.new(File::NULL)
  end
end

module Channel
  class Api; end
end

class ContactInbox; end
class Conversation; end
class Message; end

require_relative '../initializers/social_comments'

class SocialCommentsResilienceTest < Minitest::Test
  FakeMessage = Struct.new(:id, :conversation_id)
  FakeContactInbox = Struct.new(:contact_id)

  class FakeInbox
    attr_reader :id, :account_id, :account, :lock_calls

    def initialize(account)
      @id = 41
      @account_id = 1
      @account = account
      @lock_calls = 0
    end

    def with_lock
      @lock_calls += 1
      yield
    end
  end

  class FakeMessages
    attr_reader :create_calls

    def initialize(&create)
      @create = create
      @create_calls = 0
    end

    def create!(**attributes)
      @create_calls += 1
      @create.call(@create_calls, attributes)
    end
  end

  class FakeConversation
    attr_reader :id, :messages

    def initialize(messages, id: 77)
      @id = id
      @messages = messages
    end
  end

  def setup
    @restores = []
    @comment = {
      page_id: 'page-1', comment_id: 'comment-1', post_id: 'post-1',
      parent_id: nil, from_id: 'person-1', from_name: 'Person', message: 'Hello'
    }
  end

  def teardown
    @restores.reverse_each(&:call)
  end

  def test_retries_record_not_found_and_then_ingests
    messages = FakeMessages.new do |call, _attributes|
      raise ActiveRecord::RecordNotFound, 'conversation was removed' if call == 1

      FakeMessage.new(101, 77)
    end
    inbox = configure_ingest(messages)

    assert_equal :ok, SocialComments.ingest(@comment)
    assert_equal 2, messages.create_calls
    assert_equal 2, inbox.lock_calls
  end

  def test_retries_nil_destroy_from_stale_callback_and_then_ingests
    messages = FakeMessages.new do |call, _attributes|
      nil.destroy! if call == 1
      FakeMessage.new(102, 77)
    end
    inbox = configure_ingest(messages)

    assert_equal :ok, SocialComments.ingest(@comment)
    assert_equal 2, messages.create_calls
    assert_equal 2, inbox.lock_calls
  end

  def test_retries_nil_id_from_stale_callback_and_then_ingests
    messages = FakeMessages.new do |call, _attributes|
      nil.id if call == 1
      FakeMessage.new(103, 77)
    end
    inbox = configure_ingest(messages)

    assert_equal :ok, SocialComments.ingest(@comment)
    assert_equal 2, messages.create_calls
    assert_equal 2, inbox.lock_calls
  end

  def test_retries_duplicate_contact_race_instead_of_dropping_new_comment
    messages = FakeMessages.new do |call, _attributes|
      raise ActiveRecord::RecordNotUnique, 'contact inbox race' if call == 1

      FakeMessage.new(104, 77)
    end
    inbox = configure_ingest(messages)

    assert_equal :ok, SocialComments.ingest(@comment)
    assert_equal 2, messages.create_calls
    assert_equal 2, inbox.lock_calls
  end

  def test_retries_foreign_key_race_from_deleted_conversation
    messages = FakeMessages.new do |call, _attributes|
      raise ActiveRecord::InvalidForeignKey, 'conversation disappeared' if call == 1

      FakeMessage.new(105, 77)
    end
    inbox = configure_ingest(messages)

    assert_equal :ok, SocialComments.ingest(@comment)
    assert_equal 2, messages.create_calls
    assert_equal 2, inbox.lock_calls
  end

  def test_does_not_duplicate_when_callback_failed_after_commit
    messages = FakeMessages.new { |_call, _attributes| nil.destroy! }
    configure_ingest(messages)
    stub_social(:persisted_comment?) { |_comment| true }

    assert_equal :ok, SocialComments.ingest(@comment)
    assert_equal 1, messages.create_calls
  end

  def test_returns_retry_after_bounded_recoverable_failures
    messages = FakeMessages.new { |_call, _attributes| nil.id }
    inbox = configure_ingest(messages)

    assert_equal :retry, SocialComments.ingest(@comment)
    assert_equal 2, messages.create_calls
    assert_equal 2, inbox.lock_calls
  end

  def test_unrelated_no_method_error_is_not_hidden
    messages = FakeMessages.new { |_call, _attributes| nil.unexpected_social_comments_bug }
    configure_ingest(messages)

    error = assert_raises(NoMethodError) { SocialComments.ingest(@comment) }
    assert_equal :unexpected_social_comments_bug, error.name
    assert_equal 1, messages.create_calls
  end

  def test_deleted_parent_conversation_becomes_a_clean_miss
    parent = Class.new do
      attr_reader :conversation_id

      def initialize
        @conversation_id = 991
      end

      def conversation
        raise ActiveRecord::RecordNotFound, 'must not dereference stale association'
      end
    end.new
    inbox = Struct.new(:id, :account_id).new(41, 1)
    captured = nil
    original = Conversation.method(:find_by) if Conversation.respond_to?(:find_by)
    Conversation.define_singleton_method(:find_by) do |attributes|
      captured = attributes
      nil
    end

    assert_nil SocialComments.live_conversation_for(inbox, parent)
    assert_equal({ id: 991, account_id: 1, inbox_id: 41 }, captured)
  ensure
    if original
      Conversation.define_singleton_method(:find_by, original)
    else
      Conversation.singleton_class.send(:remove_method, :find_by)
    end
  end

  def test_anonymous_comment_gets_a_stable_nonempty_source
    anonymous = @comment.merge(from_id: '')

    assert_equal 'facebook-comment:comment-1', SocialComments.contact_source_id(anonymous)
    assert_equal SocialComments.contact_source_id(anonymous), SocialComments.contact_source_id(anonymous)
  end

  def test_middleware_returns_503_for_a_retryable_comment_without_delegating
    delegated = 0
    middleware = SocialCommentsMiddleware.new(lambda do |_env|
      delegated += 1
      [418, {}, ['delegated']]
    end)
    comment = @comment
    stub_social(:extract_comments) { |_payload| [comment] }
    stub_social(:valid_signature?) { |_raw, _header| true }
    stub_social(:ingest) { |_comment| :retry }

    status, _headers, body = middleware.call(feed_env)

    assert_equal 503, status
    assert_equal ['retry'], body
    assert_equal 0, delegated
  end

  def test_middleware_isolates_one_callback_exception_and_requests_retry
    middleware = SocialCommentsMiddleware.new(lambda { |_env| flunk('must not delegate recognised feed') })
    comments = [@comment, @comment.merge(comment_id: 'comment-2')]
    stub_social(:extract_comments) { |_payload| comments }
    stub_social(:valid_signature?) { |_raw, _header| true }
    calls = 0
    stub_social(:ingest) do |_comment|
      calls += 1
      raise NoMethodError, 'stale callback' if calls == 1

      :ok
    end

    status, _headers, _body = middleware.call(feed_env)

    assert_equal 503, status
    assert_equal 2, calls
  end

  def test_native_messenger_exception_is_not_swallowed_by_the_addon
    native_error = ActiveRecord::RecordNotFound.new('native messenger record disappeared')
    middleware = SocialCommentsMiddleware.new(lambda { |_env| raise native_error })
    raw = JSON.generate('entry' => [{ 'messaging' => [{ 'message' => { 'text' => 'hello' } }] }])
    env = {
      'PATH_INFO' => '/bot',
      'REQUEST_METHOD' => 'POST',
      'rack.input' => StringIO.new(raw)
    }

    raised = assert_raises(ActiveRecord::RecordNotFound) { middleware.call(env) }

    assert_same native_error, raised
  end

  def test_unhandled_feed_event_exception_is_not_swallowed_by_the_addon
    native_error = ActiveRecord::RecordNotFound.new('native feed record disappeared')
    middleware = SocialCommentsMiddleware.new(lambda { |_env| raise native_error })
    raw = JSON.generate(
      'entry' => [{ 'changes' => [{ 'field' => 'feed', 'value' => { 'item' => 'like', 'verb' => 'add' } }] }]
    )
    env = {
      'PATH_INFO' => '/bot',
      'REQUEST_METHOD' => 'POST',
      'rack.input' => StringIO.new(raw)
    }

    raised = assert_raises(ActiveRecord::RecordNotFound) { middleware.call(env) }

    assert_same native_error, raised
  end

  private

  def configure_ingest(messages)
    contacts = Object.new
    account = Struct.new(:contacts).new(contacts)
    inbox = FakeInbox.new(account)
    contact_inbox = FakeContactInbox.new(55)
    contact = Object.new
    conversation = FakeConversation.new(messages)

    stub_social(:inbox_for) { |_page_id| inbox }
    stub_social(:already_seen?) { |_the_inbox, _comment_id| false }
    stub_social(:find_or_create_contact) { |_the_inbox, _comment| contact_inbox }
    stub_social(:live_contact_for) { |_the_inbox, _contact_inbox| contact }
    stub_social(:find_or_create_conversation) { |_the_inbox, _ci, _comment| conversation }
    stub_social(:persisted_comment?) { |_comment| false }
    inbox
  end

  def stub_social(name, &implementation)
    singleton = SocialComments.singleton_class
    original = SocialComments.method(name)
    singleton.send(:define_method, name, &implementation)
    @restores << lambda { singleton.send(:define_method, name, original) }
  end

  def feed_env
    raw = JSON.generate('entry' => [{ 'changes' => [{ 'field' => 'feed' }] }])
    {
      'PATH_INFO' => '/bot',
      'REQUEST_METHOD' => 'POST',
      'rack.input' => StringIO.new(raw),
      'HTTP_X_HUB_SIGNATURE_256' => 'sha256=test'
    }
  end
end
