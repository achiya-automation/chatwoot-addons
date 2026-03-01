var isHe=LOCALE==='he';
var ARR=isHe?'ti-arrow-left':'ti-arrow-right';
var L={
  // Node categories
  trigger_cat:isHe?'\u05D8\u05E8\u05D9\u05D2\u05E8':'Trigger',
  message_cat:isHe?'\u05D4\u05D5\u05D3\u05E2\u05D4':'Message',
  logic_cat:isHe?'\u05DC\u05D5\u05D2\u05D9\u05E7\u05D4':'Logic',
  action_cat:isHe?'\u05E4\u05E2\u05D5\u05DC\u05D4':'Action',
  integration_cat:isHe?'\u05D0\u05D9\u05E0\u05D8\u05D2\u05E8\u05E6\u05D9\u05D4':'Integration',
  note_cat:isHe?'\u05D4\u05E2\u05E8\u05D4':'Note',
  // Node titles
  incoming_msg:isHe?'\u05D4\u05D5\u05D3\u05E2\u05D4 \u05E0\u05DB\u05E0\u05E1\u05EA':'Incoming Message',
  send_msg:isHe?'\u05E9\u05DC\u05D7 \u05D4\u05D5\u05D3\u05E2\u05D4':'Send Message',
  send_img:isHe?'\u05E9\u05DC\u05D7 \u05EA\u05DE\u05D5\u05E0\u05D4':'Send Image',
  send_vid:isHe?'\u05E9\u05DC\u05D7 \u05D5\u05D9\u05D3\u05D0\u05D5':'Send Video',
  buttons_title:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD':'Buttons',
  menu_title:isHe?'\u05EA\u05E4\u05E8\u05D9\u05D8':'Menu',
  condition_title:isHe?'\u05EA\u05E0\u05D0\u05D9':'Condition',
  delay_title:isHe?'\u05D4\u05DE\u05EA\u05E0\u05D4':'Delay',
  assign_title:isHe?'\u05D4\u05E7\u05E6\u05D4 \u05DC\u05E0\u05E6\u05D9\u05D2':'Assign to Agent',
  add_label_title:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05EA\u05D2\u05D9\u05EA':'Add Label',
  remove_label_title:isHe?'\u05D4\u05E1\u05E8 \u05EA\u05D2\u05D9\u05EA':'Remove Label',
  set_attr_title:isHe?'\u05E2\u05D3\u05DB\u05DF \u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Set Attribute',
  close_title:isHe?'\u05E1\u05D2\u05D5\u05E8 \u05E9\u05D9\u05D7\u05D4':'Close Conversation',
  note_title:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA':'Internal Note',
  priority_title:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA \u05E9\u05D9\u05D7\u05D4':'Set Priority',
  status_title:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1 \u05E9\u05D9\u05D7\u05D4':'Set Status',
  transfer_title:isHe?'\u05D4\u05E2\u05D1\u05E8 \u05EA\u05D9\u05D1\u05D4':'Transfer Inbox',
  wait_reply_title:isHe?'\u05D4\u05DE\u05EA\u05DF \u05DC\u05EA\u05E9\u05D5\u05D1\u05D4':'Wait for Reply',
  goto_title:isHe?'\u05E7\u05E4\u05D5\u05E5 \u05DC\u05E9\u05DC\u05D1':'Go to Step',
  // Labels
  trigger_type:isHe?'\u05E1\u05D5\u05D2 \u05D8\u05E8\u05D9\u05D2\u05E8':'Trigger type',
  keyword:isHe?'\u05DE\u05D9\u05DC\u05EA \u05DE\u05E4\u05EA\u05D7':'Keyword',
  any_msg:isHe?'\u05DB\u05DC \u05D4\u05D5\u05D3\u05E2\u05D4':'Any message',
  new_conv:isHe?'\u05E9\u05D9\u05D7\u05D4 \u05D7\u05D3\u05E9\u05D4':'New conversation',
  enter_keyword:isHe?'\u05D4\u05D6\u05DF \u05DE\u05D9\u05DC\u05D4...':'Enter keyword...',
  content:isHe?'\u05EA\u05D5\u05DB\u05DF':'Content',
  type_msg:isHe?'\u05D4\u05E7\u05DC\u05D3 \u05D4\u05D5\u05D3\u05E2\u05D4...':'Type a message...',
  img_url:isHe?'URL \u05EA\u05DE\u05D5\u05E0\u05D4':'Image URL',
  caption:isHe?'\u05DB\u05D9\u05EA\u05D5\u05D1':'Caption',
  optional:isHe?'\u05D0\u05D5\u05E4\u05E6\u05D9\u05D5\u05E0\u05DC\u05D9...':'Optional...',
  vid_url:isHe?'URL \u05D5\u05D9\u05D3\u05D0\u05D5':'Video URL',
  msg_text:isHe?'\u05D8\u05E7\u05E1\u05D8 \u05D4\u05D5\u05D3\u05E2\u05D4':'Message text',
  buttons_label:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD (\u05E2\u05D3 3)':'Buttons (up to 3)',
  btn1:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8 1':'Button 1',
  btn2:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8 2':'Button 2',
  btn3:isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8 3':'Button 3',
  title_label:isHe?'\u05DB\u05D5\u05EA\u05E8\u05EA':'Title',
  choose_option:isHe?'\u05D1\u05D7\u05E8 \u05D0\u05E4\u05E9\u05E8\u05D5\u05EA:':'Choose an option:',
  options_label:isHe?'\u05D0\u05E4\u05E9\u05E8\u05D5\u05D9\u05D5\u05EA':'Options',
  opt:isHe?'\u05D0\u05E4\u05E9\u05E8\u05D5\u05EA':'Option',
  check_label:isHe?'\u05D1\u05D3\u05D9\u05E7\u05D4':'Check',
  contains:isHe?'\u05DE\u05DB\u05D9\u05DC\u05D4':'Contains',
  equals:isHe?'\u05E9\u05D5\u05D5\u05D4 \u05DC':'Equals',
  label_exists:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E7\u05D9\u05D9\u05DE\u05EA':'Label exists',
  contact_type:isHe?'\u05E1\u05D5\u05D2 \u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact type',
  conv_status:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1 \u05E9\u05D9\u05D7\u05D4':'Conv. status',
  conv_priority:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA \u05E9\u05D9\u05D7\u05D4':'Conv. priority',
  conv_label:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E9\u05D9\u05D7\u05D4':'Conv. label',
  custom_attr:isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF \u05DE\u05D5\u05EA\u05D0\u05DD':'Custom attribute',
  contact_field:isHe?'\u05E9\u05D3\u05D4 \u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact field',
  value_label:isHe?'\u05E2\u05E8\u05DA':'Value',
  seconds:isHe?'\u05E9\u05E0\u05D9\u05D5\u05EA':'Seconds',
  typing_ind:isHe?'\u05D0\u05D9\u05E0\u05D3\u05D9\u05E7\u05D8\u05D5\u05E8 \u05D4\u05E7\u05DC\u05D3\u05D4':'Typing indicator',
  no:isHe?'\u05DC\u05D0':'No',
  yes_typing:isHe?'\u05DB\u05DF \u2014 \u05D4\u05E6\u05D2 \u05D4\u05E7\u05DC\u05D3\u05D4':'Yes \u2014 show typing',
  agent:isHe?'\u05E0\u05E6\u05D9\u05D2':'Agent',
  team:isHe?'\u05E6\u05D5\u05D5\u05EA':'Team',
  none:isHe?'\u05DC\u05DC\u05D0':'None',
  label_label:isHe?'\u05EA\u05D2\u05D9\u05EA':'Label',
  select:isHe?'\u05D1\u05D7\u05E8...':'Select...',
  attr_label:isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Attribute',
  close_resolved:isHe?'\u05D4\u05E9\u05D9\u05D7\u05D4 \u05EA\u05E1\u05D5\u05DE\u05DF \u05DB\u05E4\u05EA\u05D5\u05E8\u05D4':'Conversation will be marked as resolved',
  internal_note_ph:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA...':'Internal note...',
  priority_label:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA':'Priority',
  low:isHe?'\u05E0\u05DE\u05D5\u05DB\u05D4':'Low',
  medium:isHe?'\u05D1\u05D9\u05E0\u05D5\u05E0\u05D9\u05EA':'Medium',
  high:isHe?'\u05D2\u05D1\u05D5\u05D4\u05D4':'High',
  urgent:isHe?'\u05D3\u05D7\u05D5\u05E4\u05D4':'Urgent',
  status_label:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1':'Status',
  open:isHe?'\u05E4\u05EA\u05D5\u05D7\u05D4':'Open',
  resolved:isHe?'\u05E4\u05EA\u05D5\u05E8\u05D4':'Resolved',
  pending:isHe?'\u05DE\u05DE\u05EA\u05D9\u05E0\u05D4':'Pending',
  inbox_label:isHe?'\u05EA\u05D9\u05D1\u05EA \u05D3\u05D5\u05D0\u05E8':'Inbox',
  save_var:isHe?'\u05E9\u05DE\u05D5\u05E8 \u05EA\u05E9\u05D5\u05D1\u05D4 \u05D1\u05DE\u05E9\u05EA\u05E0\u05D4':'Save response to variable',
  timeout_sec:isHe?'Timeout (\u05E9\u05E0\u05D9\u05D5\u05EA)':'Timeout (seconds)',
  timeout_msg:isHe?'\u05D4\u05D5\u05D3\u05E2\u05EA timeout (\u05D0\u05D5\u05E4\u05E6\u05D9\u05D5\u05E0\u05DC\u05D9)':'Timeout message (optional)',
  no_reply:isHe?'\u05DC\u05D0 \u05E7\u05D9\u05D1\u05DC\u05E0\u05D5 \u05EA\u05E9\u05D5\u05D1\u05D4. \u05E0\u05E1\u05D4 \u05E9\u05D5\u05D1...':'No reply received. Try again...',
  reply_received:isHe?'\u05EA\u05E9\u05D5\u05D1\u05D4 \u05D4\u05EA\u05E7\u05D1\u05DC\u05D4':'Reply received',
  save_response:isHe?'\u05E9\u05DE\u05D5\u05E8 \u05EA\u05E9\u05D5\u05D1\u05D4 \u05D1\u05DE\u05E9\u05EA\u05E0\u05D4':'Save response to variable',
  test_name:isHe?'Name \u05D4\u05D1\u05D3\u05D9\u05E7\u05D4':'Test name',
  test_ph:isHe?'\u05D1\u05D3\u05D9\u05E7\u05EA \u05D4\u05D5\u05D3\u05E2\u05D4 A':'Message test A',
  split_pct:isHe?'\u05D0\u05D7\u05D5\u05D6 \u05E0\u05EA\u05D9\u05D1 A (%)':'Path A percentage (%)',
  target_node:isHe?'\u05E6\u05D5\u05DE\u05EA \u05D9\u05E2\u05D3':'Target node',
  select_node:isHe?'\u05D1\u05D7\u05E8 \u05E6\u05D5\u05DE\u05EA...':'Select node...',
  // Output labels
  next:isHe?'\u05D4\u05DE\u05E9\u05DA':'Next',
  yes:isHe?'\u05DB\u05DF':'Yes',
  no_out:isHe?'\u05DC\u05D0':'No',
  success:isHe?'\u05D4\u05E6\u05DC\u05D7\u05D4':'Success',
  error:isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4':'Error',
  // Summary / preview placeholders
  keyword_prefix:isHe?'\u05DE\u05D9\u05DC\u05EA \u05DE\u05E4\u05EA\u05D7: ':'Keyword: ',
  type_msg_ph:isHe?'\u05D4\u05E7\u05DC\u05D3 \u05D4\u05D5\u05D3\u05E2\u05D4...':'Type a message...',
  add_buttons_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD...':'Add buttons...',
  add_options_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05D0\u05E4\u05E9\u05E8\u05D5\u05D9\u05D5\u05EA...':'Add options...',
  img_attached:isHe?'\u05EA\u05DE\u05D5\u05E0\u05D4 \u05DE\u05E6\u05D5\u05E8\u05E4\u05EA':'Image attached',
  add_img_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05EA\u05DE\u05D5\u05E0\u05D4...':'Add image...',
  vid_attached:isHe?'\u05D5\u05D9\u05D3\u05D0\u05D5 \u05DE\u05E6\u05D5\u05E8\u05E3':'Video attached',
  add_vid_ph:isHe?'\u05D4\u05D5\u05E1\u05E3 \u05D5\u05D9\u05D3\u05D0\u05D5...':'Add video...',
  typing_label:isHe?'\u05D4\u05E7\u05DC\u05D3\u05D4':'Typing',
  delay_label:isHe?'\u05D4\u05DE\u05EA\u05E0\u05D4':'Delay',
  agent_prefix:isHe?'\u05E0\u05E6\u05D9\u05D2: ':'Agent: ',
  team_prefix:isHe?'\u05E6\u05D5\u05D5\u05EA: ':'Team: ',
  select_agent_team:isHe?'\u05D1\u05D7\u05E8 \u05E0\u05E6\u05D9\u05D2/\u05E6\u05D5\u05D5\u05EA...':'Select agent/team...',
  select_label_ph:isHe?'\u05D1\u05D7\u05E8 \u05EA\u05D2\u05D9\u05EA...':'Select label...',
  select_attr_ph:isHe?'\u05D1\u05D7\u05E8 \u05DE\u05D0\u05E4\u05D9\u05D9\u05DF...':'Select attribute...',
  enter_url_ph:isHe?'\u05D4\u05D6\u05DF URL...':'Enter URL...',
  note_ph:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA...':'Internal note...',
  select_priority_ph:isHe?'\u05D1\u05D7\u05E8 \u05E2\u05D3\u05D9\u05E4\u05D5\u05EA...':'Select priority...',
  priority_prefix:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA: ':'Priority: ',
  select_status_ph:isHe?'\u05D1\u05D7\u05E8 \u05E1\u05D8\u05D8\u05D5\u05E1...':'Select status...',
  status_prefix:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1: ':'Status: ',
  inbox_prefix:isHe?'\u05EA\u05D9\u05D1\u05D4: ':'Inbox: ',
  select_inbox_ph:isHe?'\u05D1\u05D7\u05E8 \u05EA\u05D9\u05D1\u05D4...':'Select inbox...',
  saved_in:isHe?'\u05E9\u05DE\u05D5\u05E8 \u05D1: ':'Saved in: ',
  waiting_reply:isHe?'\u05DE\u05DE\u05EA\u05D9\u05DF \u05DC\u05EA\u05E9\u05D5\u05D1\u05D4':'Waiting for reply',
  set_url_ph:isHe?'\u05D4\u05D2\u05D3\u05E8 URL...':'Set URL...',
  select_target_ph:isHe?'\u05D1\u05D7\u05E8 \u05E6\u05D5\u05DE\u05EA \u05D9\u05E2\u05D3...':'Select target node...',
  goto_node:isHe?'\u05E7\u05E4\u05D5\u05E5 \u05DC\u05E6\u05D5\u05DE\u05EA #':'Go to node #',
  // Condition check types for summary
  cond_contains:isHe?'\u05DE\u05DB\u05D9\u05DC\u05D4':'Contains',
  cond_equals:isHe?'\u05E9\u05D5\u05D5\u05D4 \u05DC':'Equals',
  cond_label_exists:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E7\u05D9\u05D9\u05DE\u05EA':'Label exists',
  cond_contact_type:isHe?'\u05E1\u05D5\u05D2 \u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact type',
  cond_conv_status:isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1':'Status',
  cond_conv_priority:isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA':'Priority',
  cond_has_label:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E9\u05D9\u05D7\u05D4':'Conv. label',
  cond_custom_attr:isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Attribute',
  cond_contact_field:isHe?'\u05E9\u05D3\u05D4':'Field',
  // Toast messages
  file_exported:isHe?'\u05E7\u05D5\u05D1\u05E5 \u05D9\u05D5\u05E6\u05D0 \u05D1\u05D4\u05E6\u05DC\u05D7\u05D4':'File exported successfully',
  import_confirm:isHe?'\u05D4\u05D9\u05D9\u05D1\u05D5\u05D0 \u05D9\u05D7\u05DC\u05D9\u05E3 \u05D0\u05EA \u05D4-flow \u05D4\u05E0\u05D5\u05DB\u05D7\u05D9. \u05DC\u05D4\u05DE\u05E9\u05D9\u05DA?':'Importing will replace the current flow. Continue?',
  invalid_file:isHe?'\u05E7\u05D5\u05D1\u05E5 \u05DC\u05D0 \u05EA\u05E7\u05D9\u05DF':'Invalid file',
  flow_imported:isHe?'Flow \u05D9\u05D5\u05D1\u05D0 \u05D1\u05D4\u05E6\u05DC\u05D7\u05D4':'Flow imported successfully',
  file_read_err:isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4 \u05D1\u05E7\u05E8\u05D9\u05D0\u05EA \u05D4\u05E7\u05D5\u05D1\u05E5':'Error reading file',
  load_err:isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4 \u05D1\u05D8\u05E2\u05D9\u05E0\u05EA \u05D4\u05D1\u05D5\u05D8':'Error loading bot',
  draft_saved:isHe?'\u05D8\u05D9\u05D5\u05D8\u05D4 \u05E0\u05E9\u05DE\u05E8\u05D4':'Draft saved',
  unsaved_changes:isHe?'\u05E9\u05D9\u05E0\u05D5\u05D9\u05D9\u05DD \u05DC\u05D0 \u05E0\u05E9\u05DE\u05E8\u05D5':'Unsaved changes',
  ls_full:isHe?'localStorage \u05DE\u05DC\u05D0 \u2014 \u05E9\u05DE\u05D5\u05E8 \u05D9\u05D3\u05E0\u05D9\u05EA':'localStorage full \u2014 save manually',
  copied:isHe?'\u05D4\u05D5\u05E2\u05EA\u05E7':'Copied',
  pasted:isHe?'\u05D4\u05D5\u05D3\u05D1\u05E7':'Pasted',
  node_duplicated:isHe?'\u05E6\u05D5\u05DE\u05EA \u05E9\u05D5\u05DB\u05E4\u05DC':'Node duplicated',
  // Draft restore
  ago_moments:isHe?'\u05DC\u05E4\u05E0\u05D9 \u05E8\u05D2\u05E2':'a moment ago',
  ago_min:isHe?'\u05DC\u05E4\u05E0\u05D9 ':'',
  ago_min_suffix:isHe?' \u05D3\u05E7\u05F3':' min ago',
  ago_hours:isHe?'\u05DC\u05E4\u05E0\u05D9 ':'',
  ago_hours_suffix:isHe?' \u05E9\u05E2\u05D5\u05EA':' hours ago',
  ago_days:isHe?'\u05DC\u05E4\u05E0\u05D9 ':'',
  ago_days_suffix:isHe?' \u05D9\u05DE\u05D9\u05DD':' days ago',
  draft_found:isHe?'\u05E0\u05DE\u05E6\u05D0\u05D4 \u05D8\u05D9\u05D5\u05D8\u05D4 \u05DE':'Draft found from ',
  draft_restore:isHe?'. \u05DC\u05E9\u05D7\u05D6\u05E8?':'. Restore?',
  // Simulator i18n
  sim_title:isHe?'\u05E1\u05D9\u05DE\u05D5\u05DC\u05D8\u05D5\u05E8 \u05E6\u05F3\u05D0\u05D8':'Chat Simulator',
  sim_start:isHe?'\u05E9\u05DC\u05D7 \u05D4\u05D5\u05D3\u05E2\u05D4 \u05DB\u05D3\u05D9 \u05DC\u05D4\u05EA\u05D7\u05D9\u05DC...':'Send a message to start...',
  sim_type_msg:isHe?'\u05D4\u05E7\u05DC\u05D3 \u05D4\u05D5\u05D3\u05E2\u05D4...':'Type a message...',
  sim_type_reply:isHe?'\u05D4\u05E7\u05DC\u05D3 \u05EA\u05E9\u05D5\u05D1\u05D4...':'Type your reply...',
  sim_flow_ended:isHe?'\u05D4\u05D6\u05E8\u05D9\u05DE\u05D4 \u05D4\u05E1\u05EA\u05D9\u05D9\u05DE\u05D4':'Flow ended',
  sim_no_trigger:isHe?'\u05DC\u05D0 \u05E0\u05DE\u05E6\u05D0 \u05D8\u05E8\u05D9\u05D2\u05E8 \u05DE\u05EA\u05D0\u05D9\u05DD':'No matching trigger found',
  sim_loop:isHe?'\u05DC\u05D5\u05DC\u05D0\u05D4 \u05D0\u05D9\u05E0\u05E1\u05D5\u05E4\u05D9\u05EA \u05D6\u05D5\u05D4\u05EA\u05D4':'Infinite loop detected',
  sim_closed:isHe?'\u05D4\u05E9\u05D9\u05D7\u05D4 \u05E0\u05E1\u05D2\u05E8\u05D4':'Conversation closed',
  sim_assigned:isHe?'\u05D4\u05D5\u05E7\u05E6\u05D4 \u05DC':'Assigned to ',
  sim_label_add:isHe?'\u05EA\u05D2\u05D9\u05EA \u05E0\u05D5\u05E1\u05E4\u05D4: ':'Label added: ',
  sim_label_rm:isHe?'\u05EA\u05D2\u05D9\u05EA \u05D4\u05D5\u05E1\u05E8\u05D4: ':'Label removed: ',
  sim_action:isHe?'\u05E4\u05E2\u05D5\u05DC\u05D4 \u05D1\u05D5\u05E6\u05E2\u05D4: ':'Action executed: ',
  sim_waiting:isHe?'\u05DE\u05DE\u05EA\u05D9\u05DF \u05DC\u05EA\u05E9\u05D5\u05D1\u05D4...':'Waiting for reply...',
  sim_timeout:isHe?'Timeout \u05D4\u05D2\u05D9\u05E2':'Timeout reached',
  sim_condition:isHe?'\u05EA\u05E0\u05D0\u05D9: ':'Condition: ',
  sim_test_bot:isHe?'\u05D1\u05D3\u05D5\u05E7 \u05D1\u05D5\u05D8':'Test Bot',
  sim_trigger_matched:isHe?'\u05D8\u05E8\u05D9\u05D2\u05E8 \u05D4\u05D5\u05E4\u05E2\u05DC':'Trigger matched',
  sim_demo_banner:isHe?'Live Demo \u2014 \u05D1\u05E4\u05E8\u05D5\u05D3\u05E7\u05E9\u05DF, \u05D6\u05D4 \u05DE\u05EA\u05D7\u05D1\u05E8 \u05DC\u05DE\u05E2\u05E8\u05DB\u05EA Chatwoot \u05E9\u05DC\u05DA \u05E2\u05DD WhatsApp \u05D0\u05DE\u05D9\u05EA\u05D9':'Live Demo \u2014 in production, this connects to your Chatwoot instance with real WhatsApp'
};
var botData = null;
var agents=[], labels=[], teams=[], inboxes=[], customAttrs=[], contactFields=[];
var dragNodeType = null;

// ===== DRAWFLOW =====
var dfEl = document.getElementById('drawflow');
var editor = new Drawflow(dfEl);
editor.reroute = false;
editor.curvature = 0.3;
editor.reroute_curvature_start_end = 0.3;
editor.reroute_curvature = 0.3;
editor.force_first_input = false;
editor.start();

// Override broken updateConnectionNodes with custom implementation
var _origUpdateConn = editor.updateConnectionNodes.bind(editor);
editor.updateConnectionNodes = function(id) {
  var pc = editor.precanvas;
  if (!pc) return;
  var pcRect = pc.getBoundingClientRect();
  var z = editor.zoom;
  var curv = editor.curvature;
  // Find all connections involving this node
  var conns = pc.querySelectorAll('.connection.node_in_' + id + ', .connection.node_out_' + id);
  conns.forEach(function(conn) {
    var classes = conn.classList;
    var nodeOutId = null, nodeInId = null, outClass = null, inClass = null;
    classes.forEach(function(c) {
      if (c.indexOf('node_out_') === 0) nodeOutId = c.replace('node_out_', '');
      if (c.indexOf('node_in_') === 0) nodeInId = c.replace('node_in_', '');
      if (c.indexOf('output_') === 0) outClass = c;
      if (c.indexOf('input_') === 0) inClass = c;
    });
    if (!nodeOutId || !nodeInId || !outClass || !inClass) return;
    var outEl = document.querySelector('#' + nodeOutId + ' .outputs .' + outClass);
    var inEl = document.querySelector('#' + nodeInId + ' .inputs .' + inClass);
    if (!outEl || !inEl) return;
    var outR = outEl.getBoundingClientRect();
    var inR = inEl.getBoundingClientRect();
    var ox = (outR.x + outR.width / 2 - pcRect.x) / z;
    var oy = (outR.y + outR.height / 2 - pcRect.y) / z;
    var ix = (inR.x + inR.width / 2 - pcRect.x) / z;
    var iy = (inR.y + inR.height / 2 - pcRect.y) / z;
    var hx = Math.abs(ix - ox) * curv;
    if (hx < 30) hx = 30;
    var d = ' M ' + ox + ' ' + oy + ' C ' + (ox + hx) + ' ' + oy + ' ' + (ix - hx) + ' ' + iy + ' ' + ix + ' ' + iy;
    var mp = conn.querySelector('.main-path');
    if (mp) mp.setAttribute('d', d);
    var hp = conn.querySelector('.hit-path');
    if (hp) hp.setAttribute('d', d);
  });
};

// Also hook into real-time drag updates via position observer
(function() {
  var dragging = false;
  var dragId = null;
  var rafId = null;
  function updateDuringDrag() {
    if (dragging && dragId) {
      editor.updateConnectionNodes('node-' + dragId);
      rafId = requestAnimationFrame(updateDuringDrag);
    }
  }
  editor.on('nodeSelected', function(id) { dragId = id; });
  dfEl.addEventListener('mousedown', function(e) {
    if (e.target.closest && e.target.closest('.drawflow-node')) {
      dragging = true;
      rafId = requestAnimationFrame(updateDuringDrag);
    }
  });
  document.addEventListener('mouseup', function() {
    dragging = false;
    if (rafId) { cancelAnimationFrame(rafId); rafId = null; }
    if (dragId) editor.updateConnectionNodes('node-' + dragId);
  });
})();

editor.on('nodeCreated', function(id){updStats();addNodeActions(id);setTimeout(function(){updateNodeSummary(id);fillGotoSelects()},200);var el=document.getElementById('node-'+id);if(el)el._createdAt=Date.now()});
editor.on('nodeRemoved', function(){updStats();setTimeout(fillGotoSelects,100)});
editor.on('connectionCreated', updStats);
editor.on('connectionRemoved', updStats);

function updStats(){
  var d=editor.export().drawflow.Home.data, nc=0, cc=0;
  for(var k in d){nc++;for(var o in d[k].outputs){cc+=(d[k].outputs[o].connections||[]).length}}
  document.getElementById('st-n').textContent=nc;
  document.getElementById('st-c').textContent=cc;
  var sbn=document.getElementById('sb-nodes');if(sbn)sbn.textContent=nc+(isHe?' \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD':' nodes');
  var sbc=document.getElementById('sb-conns');if(sbc)sbc.textContent=cc+(isHe?' \u05D7\u05D9\u05D1\u05D5\u05E8\u05D9\u05DD':' connections');
  updEmpty();
}
function updEmpty(){
  var d=editor.export().drawflow.Home.data;
  var empty=document.getElementById('canvas-empty');
  var hint=document.querySelector('.hint');
  var hasNodes=Object.keys(d).length>0;
  if(empty)empty.classList.toggle('hidden',hasNodes);
  if(hint)hint.style.display=hasNodes?'none':'';
}

function addNodeActions(id){
  var el=document.getElementById('node-'+id);
  if(!el||el.querySelector('.node-actions'))return;
  var acts=document.createElement('div');
  acts.className='node-actions';
  acts.innerHTML='<button class="na-btn na-dup" title="'+(isHe?'\u05E9\u05DB\u05E4\u05D5\u05DC':'Duplicate')+'" onclick="event.stopPropagation();duplicateNode('+id+')"><i class="ti ti-copy"></i></button><button class="na-btn na-del" title="'+(isHe?'\u05DE\u05D7\u05E7':'Delete')+'" onclick="event.stopPropagation();deselectConn();editor.removeNodeId(\'node-'+id+'\');selectedNodeId=null;hideNodeProps();markDirty()"><i class="ti ti-trash"></i></button>';
  el.appendChild(acts);
}
// Add actions to existing nodes on load
function addAllNodeActions(){
  var d=editor.export().drawflow.Home.data;
  for(var k in d)addNodeActions(k);
}

// ===== NODE CONFIG =====
var NC = {
  trigger:      {i:0, o:1, data:{trigger_type:'keyword',keyword:''}},
  message:      {i:1, o:1, data:{message:''}},
  image:        {i:1, o:1, data:{image_url:'',caption:''}},
  video:        {i:1, o:1, data:{video_url:'',caption:''}},
  buttons:      {i:1, o:3, data:{body:'',btn1:'',btn2:'',btn3:''}},
  menu:         {i:1, o:6, data:{title:'',opt1:'',opt2:'',opt3:'',opt4:'',opt5:'',opt6:''}},
  condition:    {i:1, o:2, data:{check_type:'contains',check_value:''}},
  delay:        {i:1, o:1, data:{seconds:'5',typing:'false'}},
  assign:       {i:1, o:1, data:{agent_id:'',team_id:''}},
  add_label:    {i:1, o:1, data:{label_name:''}},
  remove_label: {i:1, o:1, data:{label_name:''}},
  set_attribute:{i:1, o:1, data:{attr_key:'',attr_value:''}},
  close:        {i:1, o:0, data:{}},
  webhook:      {i:1, o:1, data:{url:'',method:'POST',headers:''}},
  note:         {i:0, o:0, data:{text:''}},
  set_priority: {i:1, o:1, data:{priority:''}},
  set_status:   {i:1, o:1, data:{status:''}},
  transfer_inbox:{i:1, o:1, data:{inbox_id:''}},
  wait_reply:   {i:1, o:2, data:{variable:'',timeout_seconds:'300',timeout_message:''}},
  api_action:   {i:1, o:2, data:{method:'GET',url:'',headers:'',body:'',save_response:''}},
  ab_split:     {i:1, o:2, data:{split_a:'50',name:''}},
  goto_step:    {i:1, o:0, data:{target_node:''}}
};

function nHtml(t){
  var tgl='<button class="nh-toggle" onclick="event.stopPropagation();toggleNodeCollapse(this)"><i class="ti ti-chevron-down"></i></button>';
  var olbNext='<div class="olb olb-single"><div class="olb-next"><span>'+L.next+'</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div></div>';
  var h={
    trigger:'<div><div class="nh nh-or"><i class="ti ti-target"></i><div class="nh-text"><span class="nh-cat">'+L.trigger_cat+'</span><span class="nh-title">'+L.incoming_msg+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.trigger_type+'</label><select df-trigger_type><option value="keyword">'+L.keyword+'</option><option value="any">'+L.any_msg+'</option><option value="first">'+L.new_conv+'</option></select><label>'+L.keyword+'</label><input type="text" df-keyword placeholder="'+L.enter_keyword+'"></div><div class="node-preview"></div></div>',
    message:'<div><div class="nh nh-bl"><i class="ti ti-message"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.send_msg+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.content+'</label><textarea df-message placeholder="'+L.type_msg+'" rows="3"></textarea></div><div class="node-preview"></div>'+olbNext+'</div>',
    image:'<div><div class="nh nh-im"><i class="ti ti-photo"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.send_img+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.img_url+'</label><input type="text" df-image_url placeholder="https://..." style="direction:ltr"><label>'+L.caption+'</label><input type="text" df-caption placeholder="'+L.optional+'"></div><div class="node-preview"></div>'+olbNext+'</div>',
    video:'<div><div class="nh nh-vi"><i class="ti ti-video"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.send_vid+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.vid_url+'</label><input type="text" df-video_url placeholder="https://..." style="direction:ltr"><label>'+L.caption+'</label><input type="text" df-caption placeholder="'+L.optional+'"></div><div class="node-preview"></div>'+olbNext+'</div>',
    buttons:'<div><div class="nh nh-bt"><i class="ti ti-click"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.buttons_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.msg_text+'</label><textarea df-body placeholder="'+L.type_msg+'" rows="2"></textarea><label>'+L.buttons_label+'</label><input type="text" df-btn1 placeholder="'+L.btn1+'"><input type="text" df-btn2 placeholder="'+L.btn2+'"><input type="text" df-btn3 placeholder="'+L.btn3+'"></div><div class="node-preview"></div><div class="olb"><div class="olb-btn-label" data-btn="1"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn1+'</span></div><div class="olb-btn-label" data-btn="2"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn2+'</span></div><div class="olb-btn-label" data-btn="3"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn3+'</span></div></div></div>',
    menu:'<div><div class="nh nh-pu"><i class="ti ti-list"></i><div class="nh-text"><span class="nh-cat">'+L.message_cat+'</span><span class="nh-title">'+L.menu_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.title_label+'</label><input type="text" df-title placeholder="'+L.choose_option+'"><label>'+L.options_label+'</label><input type="text" df-opt1 placeholder="1. ..."><input type="text" df-opt2 placeholder="2. ..."><input type="text" df-opt3 placeholder="3. ..."><input type="text" df-opt4 placeholder="4. ..."><input type="text" df-opt5 placeholder="5. ..."><input type="text" df-opt6 placeholder="6. ..."></div><div class="node-preview"></div><div class="olb"><div class="olb-btn-label" data-opt="1"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 1</span></div><div class="olb-btn-label" data-opt="2"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 2</span></div><div class="olb-btn-label" data-opt="3"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 3</span></div><div class="olb-btn-label" data-opt="4"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 4</span></div><div class="olb-btn-label" data-opt="5"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 5</span></div><div class="olb-btn-label" data-opt="6"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' 6</span></div></div></div>',
    condition:'<div><div class="nh nh-ye"><i class="ti ti-git-branch"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.condition_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.check_label+'</label><select df-check_type><option value="contains">'+L.contains+'</option><option value="equals">'+L.equals+'</option><option value="regex">Regex</option><option value="label_exists">'+L.label_exists+'</option><option value="contact_type">'+L.contact_type+'</option><option value="conversation_status">'+L.conv_status+'</option><option value="conversation_priority">'+L.conv_priority+'</option><option value="has_label">'+L.conv_label+'</option><option value="custom_attribute">'+L.custom_attr+'</option><option value="contact_field">'+L.contact_field+'</option></select><label>'+L.value_label+'</label><input type="text" df-check_value placeholder="..."></div><div class="node-preview"></div><div class="olb"><div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.yes+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.no_out+' <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    delay:'<div><div class="nh nh-dl"><i class="ti ti-clock-pause"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.delay_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.seconds+'</label><input type="number" df-seconds value="5" min="1" max="3600"><label>'+L.typing_ind+'</label><select df-typing><option value="false">'+L.no+'</option><option value="true">'+L.yes_typing+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    assign:'<div><div class="nh nh-gr"><i class="ti ti-user"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.assign_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.agent+'</label><select df-agent_id class="asel"><option value="">'+L.none+'</option></select><label>'+L.team+'</label><select df-team_id class="tsel"><option value="">'+L.none+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    add_label:'<div><div class="nh nh-tl"><i class="ti ti-tag"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.add_label_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.label_label+'</label><select df-label_name class="lsel"><option value="">'+L.select+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    remove_label:'<div><div class="nh nh-tl"><i class="ti ti-tag-off"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.remove_label_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.label_label+'</label><select df-label_name class="lsel"><option value="">'+L.select+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    set_attribute:'<div><div class="nh nh-at"><i class="ti ti-pencil"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.set_attr_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.attr_label+'</label><select df-attr_key class="casel"><option value="">'+L.select+'</option></select><label>'+L.value_label+'</label><input type="text" df-attr_value placeholder="..."></div><div class="node-preview"></div>'+olbNext+'</div>',
    close:'<div><div class="nh nh-rd"><i class="ti ti-circle-check"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.close_title+'</span></div></div><div class="node-preview"><div class="pv-info"><i class="ti ti-circle-check" style="font-size:12px"></i> '+L.close_resolved+'</div></div></div>',
    webhook:'<div><div class="nh nh-wb"><i class="ti ti-webhook"></i><div class="nh-text"><span class="nh-cat">'+L.integration_cat+'</span><span class="nh-title">Webhook</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>URL</label><input type="text" df-url placeholder="https://..." style="direction:ltr"><label>'+(isHe?'\u05DE\u05EA\u05D5\u05D3\u05D4':'Method')+'</label><select df-method><option value="POST">POST</option><option value="GET">GET</option></select><label>'+(isHe?'\u05DB\u05D5\u05EA\u05E8\u05D5\u05EA (JSON)':'Headers (JSON)')+'</label><textarea df-headers placeholder=\'{"Authorization":"Bearer ..."}\' rows="2" style="direction:ltr"></textarea></div><div class="node-preview"></div>'+olbNext+'</div>',
    note:'<div><div class="nh nh-nt"><i class="ti ti-note"></i><div class="nh-text"><span class="nh-cat">'+L.note_cat+'</span><span class="nh-title">'+L.note_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><textarea df-text placeholder="'+L.internal_note_ph+'" rows="2"></textarea></div><div class="node-preview"></div></div>',
    set_priority:'<div><div class="nh nh-sp"><i class="ti ti-flag"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.priority_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.priority_label+'</label><select df-priority><option value="">'+L.select+'</option><option value="0">'+L.low+'</option><option value="1">'+L.medium+'</option><option value="2">'+L.high+'</option><option value="3">'+L.urgent+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    set_status:'<div><div class="nh nh-ss"><i class="ti ti-toggle-right"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.status_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.status_label+'</label><select df-status><option value="">'+L.select+'</option><option value="open">'+L.open+'</option><option value="resolved">'+L.resolved+'</option><option value="pending">'+L.pending+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    transfer_inbox:'<div><div class="nh nh-ti"><i class="ti ti-transfer"></i><div class="nh-text"><span class="nh-cat">'+L.action_cat+'</span><span class="nh-title">'+L.transfer_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.inbox_label+'</label><select df-inbox_id class="ibsel"><option value="">'+L.select+'</option></select></div><div class="node-preview"></div>'+olbNext+'</div>',
    wait_reply:'<div><div class="nh nh-wr"><i class="ti ti-message-question"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.wait_reply_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.save_var+'</label><input type="text" df-variable placeholder="reply_text" style="direction:ltr"><label>'+L.timeout_sec+'</label><input type="number" df-timeout_seconds value="300" min="10" max="86400"><label>'+L.timeout_msg+'</label><textarea df-timeout_message placeholder="'+L.no_reply+'" rows="2"></textarea></div><div class="node-preview"></div><div class="olb"><div><i class="ti ti-message-check" style="font-size:10px;color:#16A34A"></i> '+L.reply_received+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-clock-x" style="font-size:10px;color:#DC2626"></i> '+(isHe?'Timeout':' Timeout')+' <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    api_action:'<div><div class="nh nh-api"><i class="ti ti-cloud-computing"></i><div class="nh-text"><span class="nh-cat">'+L.integration_cat+'</span><span class="nh-title">API Action</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+(isHe?'\u05DE\u05EA\u05D5\u05D3\u05D4':'Method')+'</label><select df-method><option value="GET">GET</option><option value="POST">POST</option><option value="PUT">PUT</option><option value="PATCH">PATCH</option><option value="DELETE">DELETE</option></select><label>URL</label><input type="text" df-url placeholder="https://api.example.com/..." style="direction:ltr"><label>'+(isHe?'\u05DB\u05D5\u05EA\u05E8\u05D5\u05EA (JSON)':'Headers (JSON)')+'</label><textarea df-headers placeholder=\'{"Authorization":"Bearer ..."}\' rows="2" style="direction:ltr"></textarea><label>'+(isHe?'\u05D2\u05D5\u05E3 (JSON)':'Body (JSON)')+'</label><textarea df-body placeholder=\'{"key":"value"}\' rows="2" style="direction:ltr"></textarea><label>'+L.save_response+'</label><input type="text" df-save_response placeholder="api_result" style="direction:ltr"></div><div class="node-preview"></div><div class="olb"><div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.success+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.error+' <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    ab_split:'<div><div class="nh nh-ab"><i class="ti ti-arrows-split-2"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">A/B Split</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.test_name+'</label><input type="text" df-name placeholder="'+L.test_ph+'"><label>'+L.split_pct+'</label><input type="number" df-split_a value="50" min="1" max="99"></div><div class="node-preview"></div><div class="olb"><div><span style="font-weight:600;color:#6366f1">A</span> <span class="olb-pct">50%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><span style="font-weight:600;color:#a855f7">B</span> <span class="olb-pct">50%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div></div></div>',
    goto_step:'<div><div class="nh nh-go"><i class="ti ti-arrow-back-up"></i><div class="nh-text"><span class="nh-cat">'+L.logic_cat+'</span><span class="nh-title">'+L.goto_title+'</span></div>'+tgl+'</div><div class="nb nb-collapsible"><label>'+L.target_node+'</label><select df-target_node class="goto-sel"><option value="">'+L.select_node+'</option></select></div><div class="node-preview"></div></div>'
  };
  return h[t]||'<div>???</div>';
}

// ===== COLLAPSIBLE NODES =====
function toggleNodeCollapse(btn){
  var nb=btn.closest('.drawflow_content_node').querySelector('.nb-collapsible');
  if(!nb)return;
  var isOpen=nb.classList.contains('nb-open');
  if(isOpen){
    nb.classList.remove('nb-open');
    btn.classList.remove('open');
    var nodeEl=btn.closest('.drawflow-node');
    if(nodeEl){
      var m=nodeEl.id.match(/node-(\d+)/);
      if(m)updateNodeSummary(m[1]);
    }
  }else{
    nb.classList.add('nb-open');
    btn.classList.add('open');
  }
  // Update Drawflow connections continuously during transition + after completion
  var nodeEl=btn.closest('.drawflow-node');
  if(nodeEl){
    var nid=nodeEl.id;
    var done=false;
    // Continuous updates during transition for smooth wire following
    var iv=setInterval(function(){editor.updateConnectionNodes(nid)},30);
    var finish=function(){if(done)return;done=true;clearInterval(iv);editor.updateConnectionNodes(nid)};
    nb.addEventListener('transitionend',function handler(e){
      if(e.propertyName==='max-height'){nb.removeEventListener('transitionend',handler);finish()}
    });
    setTimeout(finish,320);// fallback
  }
}

function getSummaryText(type,data){
  if(!data)return '';
  switch(type){
    case 'trigger':var tt=data.trigger_type||'keyword';if(tt==='any')return L.any_msg;if(tt==='first')return L.new_conv;return data.keyword?L.keyword_prefix+data.keyword:'';
    case 'message':var m=data.message||'';return m?(m.length>45?m.substring(0,45)+'\u2026':m):'';
    default:return '';
  }
}
function getSummaryHtml(type,data){
  if(!data)return '';
  switch(type){
    case 'trigger':
      var tt=data.trigger_type||'keyword';
      var label=tt==='any'?L.any_msg:tt==='first'?L.new_conv:L.keyword;
      var val=tt==='keyword'&&data.keyword?data.keyword:'';
      return '<div class="pv-trigger"><i class="ti ti-bolt" style="font-size:12px"></i> '+escHtml(label)+(val?' \u2014 <b>'+escHtml(val)+'</b>':'')+'</div>';
    case 'message':
      var m=data.message||'';
      if(!m)return '<span class="pv-empty">'+L.type_msg_ph+'</span>';
      return '<div class="pv-bubble">'+escHtml(m.length>80?m.substring(0,80)+'\u2026':m)+'</div>';
    case 'buttons':
      var bh='';
      if(data.body)bh+='<div class="pv-bubble">'+escHtml(data.body.length>60?data.body.substring(0,60)+'\u2026':data.body)+'</div>';
      var bs=[data.btn1,data.btn2,data.btn3].filter(Boolean);
      if(bs.length)bh+='<div class="pv-btns">'+bs.map(function(b){return '<span class="pv-pill">'+escHtml(b)+'</span>'}).join('')+'</div>';
      return bh||'<span class="pv-empty">'+L.add_buttons_ph+'</span>';
    case 'menu':
      var mh='';
      if(data.title)mh+='<div class="pv-bubble pv-bubble-sm">'+escHtml(data.title)+'</div>';
      var os=[data.opt1,data.opt2,data.opt3,data.opt4,data.opt5,data.opt6].filter(Boolean);
      if(os.length)mh+='<div class="pv-list">'+os.map(function(o,i){return '<div class="pv-list-item">'+(i+1)+'. '+escHtml(o)+'</div>'}).join('')+'</div>';
      return mh||'<span class="pv-empty">'+L.add_options_ph+'</span>';
    case 'image':
      return data.image_url?'<div class="pv-media"><i class="ti ti-photo"></i> '+(data.caption?escHtml(data.caption):L.img_attached)+'</div>':'<span class="pv-empty">'+L.add_img_ph+'</span>';
    case 'video':
      return data.video_url?'<div class="pv-media"><i class="ti ti-video"></i> '+(data.caption?escHtml(data.caption):L.vid_attached)+'</div>':'<span class="pv-empty">'+L.add_vid_ph+'</span>';
    case 'condition':
      var cl={contains:L.cond_contains,equals:L.cond_equals,regex:'Regex',label_exists:L.cond_label_exists,contact_type:L.cond_contact_type,conversation_status:L.cond_conv_status,conversation_priority:L.cond_conv_priority,has_label:L.cond_has_label,custom_attribute:L.cond_custom_attr,contact_field:L.cond_contact_field};
      var ct=data.check_type||'contains';var v=data.check_value||'';
      return '<div class="pv-condition"><i class="ti ti-filter" style="font-size:12px"></i> '+escHtml(cl[ct]||ct)+(v?' \u2192 <b>'+escHtml(v)+'</b>':'')+'</div>';
    case 'delay':
      var typing=data.typing==='true'?' + <i class="ti ti-keyboard" style="font-size:12px"></i> '+L.typing_label:'';
      return '<div class="pv-info"><i class="ti ti-clock-pause" style="font-size:14px"></i> '+L.delay_label+' '+(data.seconds||5)+' '+L.seconds+typing+'</div>';
    case 'assign':
      var pa=[];
      if(data.agent_id){var ag=agents.find(function(a){return String(a.id)===String(data.agent_id)});if(ag)pa.push(L.agent_prefix+ag.name)}
      if(data.team_id){var tm=teams.find(function(t){return String(t.id)===String(data.team_id)});if(tm)pa.push(L.team_prefix+tm.name)}
      return pa.length?'<div class="pv-info"><i class="ti ti-user" style="font-size:14px"></i> '+escHtml(pa.join(' \u00B7 '))+'</div>':'<span class="pv-empty">'+L.select_agent_team+'</span>';
    case 'add_label':
      return data.label_name?'<div class="pv-info"><i class="ti ti-tag" style="font-size:14px"></i> '+escHtml(data.label_name)+'</div>':'<span class="pv-empty">'+L.select_label_ph+'</span>';
    case 'remove_label':
      return data.label_name?'<div class="pv-info"><i class="ti ti-tag-off" style="font-size:14px"></i> '+escHtml(data.label_name)+'</div>':'<span class="pv-empty">'+L.select_label_ph+'</span>';
    case 'set_attribute':
      return data.attr_key?'<div class="pv-info"><i class="ti ti-pencil" style="font-size:14px"></i> '+escHtml(data.attr_key)+' = '+(data.attr_value?escHtml(data.attr_value):'\u2014')+'</div>':'<span class="pv-empty">'+L.select_attr_ph+'</span>';
    case 'close':return '';
    case 'webhook':
      return data.url?'<div class="pv-info"><i class="ti ti-webhook" style="font-size:14px"></i> '+(data.method||'POST')+' \u2192 '+escHtml(data.url.length>30?data.url.substring(0,30)+'\u2026':data.url)+'</div>':'<span class="pv-empty">'+L.enter_url_ph+'</span>';
    case 'note':
      var nt=data.text||'';
      return nt?'<div class="pv-bubble" style="background:var(--note-bg);border:1px solid var(--note-border)">'+escHtml(nt.length>60?nt.substring(0,60)+'\u2026':nt)+'</div>':'<span class="pv-empty">'+L.note_ph+'</span>';
    case 'set_priority':
      var pm={'0':L.low,'1':L.medium,'2':L.high,'3':L.urgent};
      return pm[data.priority]?'<div class="pv-info"><i class="ti ti-flag" style="font-size:14px"></i> '+L.priority_prefix+escHtml(pm[data.priority])+'</div>':'<span class="pv-empty">'+L.select_priority_ph+'</span>';
    case 'set_status':
      var sm={'open':L.open,'resolved':L.resolved,'pending':L.pending};
      return sm[data.status]?'<div class="pv-info"><i class="ti ti-toggle-right" style="font-size:14px"></i> '+L.status_prefix+escHtml(sm[data.status])+'</div>':'<span class="pv-empty">'+L.select_status_ph+'</span>';
    case 'transfer_inbox':
      if(data.inbox_id){var ib=inboxes.find(function(i){return String(i.id)===String(data.inbox_id)});if(ib)return '<div class="pv-info"><i class="ti ti-transfer" style="font-size:14px"></i> '+L.inbox_prefix+escHtml(ib.name)+'</div>'}
      return '<span class="pv-empty">'+L.select_inbox_ph+'</span>';
    case 'wait_reply':
      var wr='<div class="pv-wait"><i class="ti ti-message-question" style="font-size:12px"></i> ';
      wr+=data.variable?L.saved_in+'<b>{{'+escHtml(data.variable)+'}}</b>':L.waiting_reply;
      wr+='</div>';
      if(data.timeout_seconds)wr+='<div class="pv-info" style="margin-top:4px"><i class="ti ti-clock" style="font-size:11px"></i> Timeout: '+data.timeout_seconds+' '+L.seconds+'</div>';
      return wr;
    case 'api_action':
      if(!data.url)return '<div class="pv-api"><i class="ti ti-cloud-computing" style="font-size:12px"></i> '+L.set_url_ph+'</div>';
      var ah='<div class="pv-api"><span style="font-weight:700;font-size:10px;background:rgba(67,56,202,.15);padding:2px 6px;border-radius:4px">'+(data.method||'GET')+'</span> '+escHtml(data.url.length>35?data.url.substring(0,35)+'\u2026':data.url)+'</div>';
      if(data.save_response)ah+='<div class="pv-info" style="margin-top:3px"><i class="ti ti-variable" style="font-size:11px"></i> \u2192 {{'+escHtml(data.save_response)+'}}</div>';
      return ah;
    case 'ab_split':
      var sa=parseInt(data.split_a)||50;var sb=100-sa;
      return '<div class="pv-split"><span style="font-weight:700;background:rgba(99,102,241,.15);padding:1px 8px;border-radius:10px;color:#6366f1">A: '+sa+'%</span> <span style="font-weight:700;background:rgba(168,85,247,.15);padding:1px 8px;border-radius:10px;color:#a855f7">B: '+sb+'%</span>'+(data.name?' <span style="opacity:.7">\u2014 '+escHtml(data.name)+'</span>':'')+'</div>';
    case 'goto_step':
      if(!data.target_node)return '<div class="pv-goto"><i class="ti ti-arrow-back-up" style="font-size:12px"></i> '+L.select_target_ph+'</div>';
      return '<div class="pv-goto"><i class="ti ti-arrow-back-up" style="font-size:14px"></i> '+L.goto_node+escHtml(data.target_node)+'</div>';
    default:return '';
  }
}

function updateNodeSummary(id){
  var nd=editor.getNodeFromId(id);
  if(!nd)return;
  var el=document.getElementById('node-'+id);
  if(!el)return;
  var html=getSummaryHtml(nd.name,nd.data);
  // Update node-preview with rich HTML
  var prev=el.querySelector('.node-preview');
  if(prev)prev.innerHTML=html;
  // Update olb button/option labels
  if(nd.name==='buttons'){
    var bls=el.querySelectorAll('.olb-btn-label[data-btn] span');
    var bd=[nd.data.btn1,nd.data.btn2,nd.data.btn3];
    for(var bi=0;bi<bls.length;bi++){bls[bi].textContent=bd[bi]||(L.btn1.replace(/\d/,''+(bi+1)))}
  }else if(nd.name==='menu'){
    var ols=el.querySelectorAll('.olb-btn-label[data-opt] span');
    var od=[nd.data.opt1,nd.data.opt2,nd.data.opt3,nd.data.opt4,nd.data.opt5,nd.data.opt6];
    for(var oi=0;oi<ols.length;oi++){ols[oi].textContent=od[oi]||(L.opt+' '+(oi+1))}
  }else if(nd.name==='ab_split'){
    var pcts=el.querySelectorAll('.olb-pct');
    var sa=parseInt(nd.data.split_a)||50;
    if(pcts.length>=2){pcts[0].textContent=sa+'%';pcts[1].textContent=(100-sa)+'%'}
  }
}

function updateAllSummaries(){
  var d=editor.export().drawflow.Home.data;
  for(var k in d)updateNodeSummary(k);
}

// ===== UPGRADE OLD SAVED NODES =====
// Drawflow stores HTML at creation time. Saved bots have old HTML without nh-text/nh-cat.
// This function upgrades old nodes after editor.import() to match the new ManyChat-style layout.
function upgradeLoadedNodes(){
  var data=editor.export().drawflow.Home.data;
  var meta={
    trigger:{icon:'ti-target',cat:L.trigger_cat,title:L.incoming_msg},
    message:{icon:'ti-message',cat:L.message_cat,title:L.send_msg},
    image:{icon:'ti-photo',cat:L.message_cat,title:L.send_img},
    video:{icon:'ti-video',cat:L.message_cat,title:L.send_vid},
    buttons:{icon:'ti-click',cat:L.message_cat,title:L.buttons_title},
    menu:{icon:'ti-list',cat:L.message_cat,title:L.menu_title},
    condition:{icon:'ti-git-branch',cat:L.logic_cat,title:L.condition_title},
    delay:{icon:'ti-clock-pause',cat:L.logic_cat,title:L.delay_title},
    assign:{icon:'ti-user',cat:L.action_cat,title:L.assign_title},
    add_label:{icon:'ti-tag',cat:L.action_cat,title:L.add_label_title},
    remove_label:{icon:'ti-tag-off',cat:L.action_cat,title:L.remove_label_title},
    set_attribute:{icon:'ti-pencil',cat:L.action_cat,title:L.set_attr_title},
    close:{icon:'ti-circle-check',cat:L.action_cat,title:L.close_title},
    webhook:{icon:'ti-webhook',cat:L.integration_cat,title:'Webhook'},
    note:{icon:'ti-note',cat:L.note_cat,title:L.note_title},
    set_priority:{icon:'ti-flag',cat:L.action_cat,title:L.priority_title},
    set_status:{icon:'ti-toggle-right',cat:L.action_cat,title:L.status_title},
    transfer_inbox:{icon:'ti-transfer',cat:L.action_cat,title:L.transfer_title},
    wait_reply:{icon:'ti-message-question',cat:L.logic_cat,title:L.wait_reply_title},
    api_action:{icon:'ti-cloud-computing',cat:L.integration_cat,title:'API Action'},
    ab_split:{icon:'ti-arrows-split-2',cat:L.logic_cat,title:'A/B Split'},
    goto_step:{icon:'ti-arrow-back-up',cat:L.logic_cat,title:L.goto_title}
  };
  var singleTypes=['trigger','message','image','video','delay','assign','add_label','remove_label','set_attribute','webhook','set_priority','set_status','transfer_inbox'];
  for(var id in data){
    var nd=data[id];
    var el=document.getElementById('node-'+id);
    if(!el)continue;
    var m=meta[nd.name];
    if(!m)continue;
    // Skip if already upgraded (has nh-text)
    if(el.querySelector('.nh-text'))continue;
    // 1. Upgrade header: add nh-text structure
    var nh=el.querySelector('.nh');
    if(nh){
      var icon=nh.querySelector('i');
      var toggle=nh.querySelector('.nh-toggle');
      // Remove everything between icon and toggle (old text nodes/spans)
      if(icon){
        while(icon.nextSibling&&icon.nextSibling!==toggle){
          nh.removeChild(icon.nextSibling);
        }
      }
      // Insert nh-text
      var td=document.createElement('div');
      td.className='nh-text';
      td.innerHTML='<span class="nh-cat">'+m.cat+'</span><span class="nh-title">'+m.title+'</span>';
      if(toggle)nh.insertBefore(td,toggle);
      else if(icon)icon.insertAdjacentElement('afterend',td);
      else nh.appendChild(td);
    }
    // 2. Collapse node
    var nb=el.querySelector('.nb-collapsible');
    if(nb)nb.classList.remove('nb-open');
    var tgl=el.querySelector('.nh-toggle');
    if(tgl)tgl.classList.remove('open');
    // 3. Ensure node-preview exists
    var prev=el.querySelector('.node-preview');
    if(!prev){
      prev=document.createElement('div');
      prev.className='node-preview';
      var nbEl=el.querySelector('.nb-collapsible');
      var olbEl=el.querySelector('.olb');
      var ctn=el.querySelector('.drawflow_content_node>div');
      if(nbEl&&nbEl.nextSibling)nbEl.parentNode.insertBefore(prev,nbEl.nextSibling);
      else if(olbEl)olbEl.parentNode.insertBefore(prev,olbEl);
      else if(ctn)ctn.appendChild(prev);
    }
    // 4. Upgrade or create olb labels (not for trigger/close/note which have no olb in new design)
    var olb=el.querySelector('.olb');
    var needsOlb=nd.name!=='trigger'&&nd.name!=='close'&&nd.name!=='note'&&NC[nd.name]&&NC[nd.name].o>0;
    if(!olb&&needsOlb){
      // Create olb when missing
      olb=document.createElement('div');
      olb.className='olb';
      var ctn=el.querySelector('.drawflow_content_node>div');
      if(ctn)ctn.appendChild(olb);
    }
    if(olb&&!olb.querySelector('.olb-next')&&!olb.querySelector('.olb-btn-label')){
      if(nd.name==='buttons'){
        olb.innerHTML='<div class="olb-btn-label" data-btn="1"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn1+'</span></div><div class="olb-btn-label" data-btn="2"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn2+'</span></div><div class="olb-btn-label" data-btn="3"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.btn3+'</span></div>';
      }else if(nd.name==='menu'){
        var mh='';for(var oi=1;oi<=6;oi++)mh+='<div class="olb-btn-label" data-opt="'+oi+'"><i class="ti '+ARR+'" style="font-size:10px"></i> <span>'+L.opt+' '+oi+'</span></div>';
        olb.innerHTML=mh;
      }else if(nd.name==='condition'){
        olb.innerHTML='<div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.yes+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.no_out+' <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else if(nd.name==='wait_reply'){
        olb.innerHTML='<div><i class="ti ti-message-check" style="font-size:10px;color:#16A34A"></i> '+L.reply_received+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-clock-x" style="font-size:10px;color:#DC2626"></i> Timeout <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else if(nd.name==='api_action'){
        olb.innerHTML='<div><i class="ti ti-check" style="font-size:10px;color:#16A34A"></i> '+L.success+' <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><i class="ti ti-x" style="font-size:10px;color:#DC2626"></i> '+L.error+' <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else if(nd.name==='ab_split'){
        var sa=parseInt(nd.data.split_a)||50;
        olb.innerHTML='<div><span style="font-weight:600;color:#6366f1">A</span> <span class="olb-pct">'+sa+'%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div><div><span style="font-weight:600;color:#a855f7">B</span> <span class="olb-pct">'+(100-sa)+'%</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }else{
        olb.className='olb olb-single';
        olb.innerHTML='<div class="olb-next"><span>'+L.next+'</span> <i class="ti '+ARR+'" style="font-size:10px"></i></div>';
      }
    }
  }
}

// ===== CONDITION INLINE DYNAMIC FIELDS =====
// When check_type dropdown changes inside a condition node, swap the value field
function getInlineOpts(ct){
  switch(ct){
    case 'contact_type':return [['0',isHe?'\u05DE\u05D1\u05E7\u05E8':'Visitor'],['1',isHe?'\u05DC\u05D9\u05D3':'Lead'],['2',isHe?'\u05DC\u05E7\u05D5\u05D7':'Customer']];
    case 'conversation_status':return [['open',isHe?L.open:'Open'],['resolved',isHe?L.resolved:'Resolved'],['pending',isHe?L.pending:'Pending'],['snoozed',isHe?'\u05D1\u05D4\u05E9\u05D4\u05D9\u05D4':'Snoozed']];
    case 'conversation_priority':return [['0',isHe?L.low:'Low'],['1',isHe?L.medium:'Medium'],['2',isHe?L.high:'High'],['3',isHe?L.urgent:'Urgent']];
    case 'has_label':return labels.map(function(l){return [l.title,l.title]});
    case 'label_exists':return labels.map(function(l){return [l.title,l.title]});
    default:return null;
  }
}

dfEl.addEventListener('change',function(e){
  if(!e.target.hasAttribute('df-check_type'))return;
  var nodeEl=e.target.closest('.drawflow-node');
  if(!nodeEl)return;
  var ct=e.target.value;
  var nb=nodeEl.querySelector('.nb');
  if(!nb)return;
  // Find old value input/select
  var oldVal=nb.querySelector('[df-check_value]');
  if(!oldVal)return;
  var opts=getInlineOpts(ct);
  if(opts){
    // Replace text input with select
    var sel=document.createElement('select');
    sel.setAttribute('df-check_value','');
    var ph=document.createElement('option');ph.value='';ph.textContent='Select...';sel.appendChild(ph);
    for(var i=0;i<opts.length;i++){
      var o=document.createElement('option');o.value=opts[i][0];o.textContent=opts[i][1];sel.appendChild(o);
    }
    oldVal.replaceWith(sel);
    // Also open the node if collapsed
    var nbCol=nodeEl.querySelector('.nb-collapsible');
    var toggle=nodeEl.querySelector('.nh-toggle');
    if(nbCol&&!nbCol.classList.contains('nb-open')){
      nbCol.classList.add('nb-open');
      if(toggle)toggle.classList.add('open');
      var iv2=setInterval(function(){editor.updateConnectionNodes(nodeEl.id)},30);
      nbCol.addEventListener('transitionend',function h2(e){if(e.propertyName==='max-height'){nbCol.removeEventListener('transitionend',h2);clearInterval(iv2);editor.updateConnectionNodes(nodeEl.id)}});
      setTimeout(function(){clearInterval(iv2);editor.updateConnectionNodes(nodeEl.id)},320);
    }
  } else {
    // Replace select with text input
    if(oldVal.tagName==='SELECT'){
      var inp=document.createElement('input');
      inp.type='text';inp.setAttribute('df-check_value','');inp.placeholder='...';
      oldVal.replaceWith(inp);
    }
  }
  // Update node data
  var m=nodeEl.id.match(/node-(\d+)/);
  if(m){
    var nd=editor.getNodeFromId(m[1]);
    if(nd){nd.data.check_value='';editor.updateNodeDataFromId(m[1],nd.data);updateNodeSummary(m[1]);markDirty();pushUndo()}
  }
});

// ===== DRAG & DROP (dual: click-to-place + HTML5 DnD) =====
var selectedNodeType = null;
var dns = document.querySelectorAll('.dn[draggable]');

function clearNodeSelection(){
  for(var j=0;j<dns.length;j++){dns[j].classList.remove('dn-selected')}
  dfEl.style.cursor='';
}

for(var i=0;i<dns.length;i++){
  (function(el){
    // HTML5 DnD: dragstart with preview
    el.addEventListener('dragstart', function(ev){
      dragNodeType = this.getAttribute('data-node');
      ev.dataTransfer.setData('text/plain', dragNodeType);
      ev.dataTransfer.effectAllowed = 'move';
      var ghost=this.cloneNode(true);
      ghost.style.cssText='position:absolute;left:-9999px;width:200px;opacity:.85;border-radius:12px;overflow:hidden;pointer-events:none;background:var(--bg-node);box-shadow:0 4px 16px rgba(0,0,0,.12)';
      document.body.appendChild(ghost);
      ev.dataTransfer.setDragImage(ghost,100,20);
      setTimeout(function(){if(ghost.parentNode)ghost.parentNode.removeChild(ghost)},60);
    });
    el.addEventListener('dragend', function(){ dragNodeType = null; });

    // Click-to-place: click sidebar node, then click canvas
    el.addEventListener('click', function(ev){
      ev.stopPropagation();
      var t = this.getAttribute('data-node');
      if(selectedNodeType === t){ selectedNodeType=null; clearNodeSelection(); return; }
      selectedNodeType = t;
      clearNodeSelection();
      this.classList.add('dn-selected');
      dfEl.style.cursor = 'crosshair';
    });
  })(dns[i]);
}

// Document-level DnD handlers (bypass Drawflow event interception)
document.addEventListener('dragover', function(e){ if(dragNodeType) e.preventDefault(); }, false);
document.addEventListener('drop', function(e){
  if(!dragNodeType) return;
  e.preventDefault();
  // Check if drop is over the canvas area
  var canvasEl = document.querySelector('.canvas');
  var rect = canvasEl.getBoundingClientRect();
  if(e.clientX < rect.left || e.clientX > rect.right || e.clientY < rect.top || e.clientY > rect.bottom){
    dragNodeType = null; return;
  }
  addNodeAt(dragNodeType, e.clientX, e.clientY);
  dragNodeType = null;
}, false);

// Click-to-place on canvas
dfEl.addEventListener('click', function(e){
  if(!selectedNodeType) return;
  if(e.target.closest && e.target.closest('.drawflow-node')) return;
  addNodeAt(selectedNodeType, e.clientX, e.clientY);
  selectedNodeType = null;
  clearNodeSelection();
});

// Shared: add node at screen position
function addNodeAt(type, clientX, clientY){
  if(!type || !NC[type]) return;
  var c = NC[type];
  var rect = editor.precanvas.getBoundingClientRect();
  var pos_x = (clientX - rect.x) / editor.zoom;
  var pos_y = (clientY - rect.y) / editor.zoom;
  editor.addNode(type, c.i, c.o, pos_x, pos_y, type, JSON.parse(JSON.stringify(c.data)), nHtml(type));
  setTimeout(popSelects, 150);
}

// ===== SELECTS =====
function popSelects(){
  fillAll('.asel',agents,'id','name',isHe?L.none:'None');
  fillAll('.tsel',teams,'id','name',isHe?L.none:'None');
  fillAll('.lsel',labels,'title','title',isHe?L.select:'Select...');
  fillAll('.ibsel',inboxes,'id','name',isHe?L.select:'Select...');
  fillAllCA('.casel',customAttrs);
  fillGotoSelects();
}
function fillGotoSelects(){
  var sels=document.querySelectorAll('.goto-sel');
  if(!sels.length)return;
  var d=editor.export().drawflow.Home.data;
  var nodes=[];
  for(var nid in d){
    var nd=d[nid];
    if(nd.name==='goto_step')continue;
    var m=isHe?{trigger:'\u05D8\u05E8\u05D9\u05D2\u05E8',message:'\u05D4\u05D5\u05D3\u05E2\u05D4',buttons:'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD',menu:'\u05EA\u05E4\u05E8\u05D9\u05D8',condition:'\u05EA\u05E0\u05D0\u05D9',delay:'\u05D4\u05DE\u05EA\u05E0\u05D4',image:'\u05EA\u05DE\u05D5\u05E0\u05D4',video:'\u05D5\u05D9\u05D3\u05D0\u05D5',assign:'\u05D4\u05E7\u05E6\u05D4',add_label:'\u05EA\u05D2\u05D9\u05EA+',remove_label:'\u05EA\u05D2\u05D9\u05EA-',set_attribute:'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF',webhook:'Webhook',close:'\u05E1\u05D2\u05D5\u05E8',note:'\u05D4\u05E2\u05E8\u05D4',set_priority:'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA',set_status:'\u05E1\u05D8\u05D8\u05D5\u05E1',transfer_inbox:'\u05D4\u05E2\u05D1\u05E8\u05D4',wait_reply:'\u05D4\u05DE\u05EA\u05E0\u05D4 \u05DC\u05EA\u05E9\u05D5\u05D1\u05D4',api_action:'API',ab_split:'A/B'}:{trigger:'Trigger',message:'Message',buttons:'Buttons',menu:'Menu',condition:'Condition',delay:'Delay',image:'Image',video:'Video',assign:'Assign',add_label:'Label+',remove_label:'Label-',set_attribute:'Attribute',webhook:'Webhook',close:'Close',note:'Note',set_priority:'Priority',set_status:'Status',transfer_inbox:'Transfer',wait_reply:'Wait Reply',api_action:'API',ab_split:'A/B'};
    nodes.push({id:nid,label:'#'+nid+' '+(m[nd.name]||nd.name)});
  }
  for(var i=0;i<sels.length;i++){
    var s=sels[i],cv=s.value;
    while(s.options.length>0)s.remove(0);
    var ph=document.createElement('option');ph.value='';ph.textContent=isHe?'\u05D1\u05D7\u05E8 \u05E6\u05D5\u05DE\u05EA...':'Select node...';s.appendChild(ph);
    for(var j=0;j<nodes.length;j++){
      var o=document.createElement('option');o.value=nodes[j].id;o.textContent=nodes[j].label;
      if(cv===nodes[j].id)o.selected=true;
      s.appendChild(o);
    }
  }
}
function fillAllCA(cls,items){
  var sels=document.querySelectorAll(cls);
  for(var i=0;i<sels.length;i++){
    var s=sels[i],cv=s.value;
    while(s.options.length>0)s.remove(0);
    var d=document.createElement('option');d.value='';d.textContent=isHe?L.select:'Select...';s.appendChild(d);
    var contactAttrs=items.filter(function(a){return a.model===0||a.model==='contact_attribute'});
    var convAttrs=items.filter(function(a){return a.model===1||a.model==='conversation_attribute'});
    if(contactAttrs.length){
      var og=document.createElement('optgroup');og.label=isHe?'\u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact';
      for(var j=0;j<contactAttrs.length;j++){var o=document.createElement('option');o.value=contactAttrs[j].key;o.textContent=contactAttrs[j].name;if(cv===contactAttrs[j].key)o.selected=true;og.appendChild(o)}
      s.appendChild(og);
    }
    if(convAttrs.length){
      var og=document.createElement('optgroup');og.label=isHe?'\u05E9\u05D9\u05D7\u05D4':'Conversation';
      for(var j=0;j<convAttrs.length;j++){var o=document.createElement('option');o.value=convAttrs[j].key;o.textContent=convAttrs[j].name;if(cv===convAttrs[j].key)o.selected=true;og.appendChild(o)}
      s.appendChild(og);
    }
  }
}
function fillAll(cls,items,vk,tk,ph){
  var sels=document.querySelectorAll(cls);
  for(var i=0;i<sels.length;i++){
    var s=sels[i],cv=s.value;
    while(s.options.length>0)s.remove(0);
    var d=document.createElement('option');d.value='';d.textContent=ph;s.appendChild(d);
    for(var j=0;j<items.length;j++){
      var o=document.createElement('option');o.value=items[j][vk];o.textContent=items[j][tk];
      if(String(cv)===String(items[j][vk]))o.selected=true;
      s.appendChild(o);
    }
  }
}

// ===== INBOXES =====
function renderInboxes(){
  var el=document.getElementById('inbox-list');
  while(el.firstChild)el.removeChild(el.firstChild);
  var sel=botData?(botData.inbox_ids||[]):[];
  if(!inboxes.length){
    var m=document.createElement('div');m.style.cssText='color:#555;font-size:12px;padding:8px';
    m.textContent='No inboxes found';el.appendChild(m);return;
  }
  for(var i=0;i<inboxes.length;i++){
    (function(ib){
      var d=document.createElement('div');
      d.className='inbox-item'+(sel.indexOf(ib.id)!==-1?' sel':'');
      var cb=document.createElement('input');cb.type='checkbox';cb.value=ib.id;
      cb.checked=sel.indexOf(ib.id)!==-1;
      var sp=document.createElement('span');sp.textContent=ib.name;
      var sm=document.createElement('small');sm.textContent=ib.channel_type?ib.channel_type.split('::').pop():'';
      d.appendChild(cb);d.appendChild(sp);d.appendChild(sm);
      d.addEventListener('click',function(e){if(e.target!==cb)cb.checked=!cb.checked;d.className='inbox-item'+(cb.checked?' sel':'')});
      el.appendChild(d);
    })(inboxes[i]);
  }
}

// ===== API =====
function fetchT(url,opts,ms){
  var ctrl=new AbortController();opts=Object.assign({},opts||{},{signal:ctrl.signal});
  var t=setTimeout(function(){ctrl.abort()},ms||30000);
  return fetch(url,opts).finally(function(){clearTimeout(t)});
}
function safeFetch(url){
  return fetchT(url).then(function(r){ return r.ok ? r.json() : []; }).catch(function(){ return []; });
}
function loadMeta(){
  return Promise.all([
    safeFetch('/bot-builder/api/agents'),
    safeFetch('/bot-builder/api/labels'),
    safeFetch('/bot-builder/api/teams'),
    safeFetch('/bot-builder/api/inboxes'),
    safeFetch('/bot-builder/api/custom_attributes'),
    safeFetch('/bot-builder/api/contact_fields')
  ]).then(function(r){
    agents=r[0]||[];labels=r[1]||[];teams=r[2]||[];inboxes=r[3]||[];customAttrs=r[4]||[];contactFields=r[5]||[];
    console.log('[BotBuilder] Loaded: agents='+agents.length+' labels='+labels.length+' teams='+teams.length+' inboxes='+inboxes.length+' customAttrs='+customAttrs.length+' contactFields='+contactFields.length);
    renderInboxes();popSelects();
  });
}

// ===== EXPORT / IMPORT =====
function downloadFlow(){
  var d=editor.export();
  var name=(document.getElementById('bname').value.trim()||'bot')+'.json';
  var blob=new Blob([JSON.stringify(d,null,2)],{type:'application/json'});
  var a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=name;
  document.body.appendChild(a);a.click();document.body.removeChild(a);URL.revokeObjectURL(a.href);
  toast(L.file_exported,'ok');
}
function importFlow(inp){
  var f=inp.files[0];if(!f)return;
  if(!confirm(L.import_confirm)){inp.value='';return}
  var r=new FileReader();
  r.onload=function(ev){
    try{
      var d=JSON.parse(ev.target.result);
      if(!d.drawflow){toast(L.invalid_file,'err');return}
      pushUndo();editor.import(d);
      setTimeout(function(){popSelects();updStats();addAllNodeActions();upgradeLoadedNodes();updateAllSummaries();addConnHitAreas()},200);
      markDirty();pushUndo();
      toast(L.flow_imported,'ok');
    }catch(ex){toast(L.file_read_err,'err')}
  };
  r.readAsText(f);inp.value='';
}

// ===== SAVE =====
var saving=false;
document.getElementById('savebtn').addEventListener('click',function(){
  var btn=this;
  if(saving)return;
  var name=document.getElementById('bname').value.trim();
  if(!name){toast(isHe?'\u05D4\u05D6\u05DF \u05E9\u05DD \u05DC\u05D1\u05D5\u05D8':'Enter a bot name','err');return}
  saving=true;btn.disabled=true;btn.innerHTML='<i class="ti ti-loader-2" style="font-size:16px;animation:spin .7s linear infinite"></i> '+(isHe?'\u05E9\u05D5\u05DE\u05E8...':'Saving...');
  var cbs=document.querySelectorAll('#inbox-list input:checked'),ids=[];
  for(var i=0;i<cbs.length;i++)ids.push(parseInt(cbs[i].value));
  var data={
    id:BOT_ID||(botData?botData.id:null),
    name:name,
    description:document.getElementById('bdesc').value.trim(),
    inbox_ids:ids,
    active:botData?(botData.active!==false):true,
    flow:editor.export()
  };
  fetchT('/bot-builder/api/bots',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)},30000)
    .then(function(r){if(!r.ok)throw new Error();return r.json()})
    .then(function(s){
      botData=s;
      if(!BOT_ID){BOT_ID=s.id;history.replaceState(null,'','/bot-builder/'+s.id+'/edit')}
      document.getElementById('st-s').textContent=s.active?(isHe?'\u05E4\u05E2\u05D9\u05DC':'Active'):(isHe?'\u05DE\u05D5\u05E9\u05D1\u05EA':'Disabled');
      document.getElementById('st-u').textContent=isHe?'\u05D4\u05E8\u05D2\u05E2':'Just now';
      toast(isHe?'\u05D4\u05D1\u05D5\u05D8 \u05E0\u05E9\u05DE\u05E8 \u05D1\u05D4\u05E6\u05DC\u05D7\u05D4!':'Bot saved successfully!','ok');markSaved();
      if(BOT_ID)try{localStorage.removeItem('bot-draft-'+BOT_ID)}catch(ex){}
    }).catch(function(err){toast(err&&err.name==='AbortError'?(isHe?'\u05D4\u05E9\u05DE\u05D9\u05E8\u05D4 \u05E0\u05DB\u05E9\u05DC\u05D4 \u2014 timeout':'Save failed \u2014 timeout'):(isHe?'\u05E9\u05D2\u05D9\u05D0\u05D4 \u05D1\u05E9\u05DE\u05D9\u05E8\u05D4':'Error saving'),'err')})
    .finally(function(){saving=false;btn.disabled=false;btn.innerHTML='<i class="ti ti-device-floppy"></i> '+(isHe?'\u05E9\u05DE\u05D5\u05E8':'Save')});
});

// ===== LOAD =====
function loadBot(id){
  fetchT('/bot-builder/api/bots/'+encodeURIComponent(id),null,30000)
    .then(function(r){return r.ok?r.json():null})
    .then(function(d){
      if(!d)return;botData=d;
      document.getElementById('bname').value=d.name||'';
      document.getElementById('bdesc').value=d.description||'';
      document.getElementById('st-s').textContent=d.active?(isHe?'\u05E4\u05E2\u05D9\u05DC':'Active'):(isHe?'\u05DE\u05D5\u05E9\u05D1\u05EA':'Disabled');
      try{var t=new Date(d.updated_at);document.getElementById('st-u').textContent=t.toLocaleDateString('he-IL')+' '+t.toLocaleTimeString('he-IL',{hour:'2-digit',minute:'2-digit'})}catch(e){}
      // Check for unsaved draft
      var useDraft=false;
      try{
        var draft=localStorage.getItem('bot-draft-'+id);
        if(draft){var dd=JSON.parse(draft);if(dd.ts&&d.updated_at&&dd.ts>new Date(d.updated_at).getTime()){var ago=(function(t){var m=Math.round((Date.now()-t)/60000);if(m<1)return L.ago_moments;if(m<60)return L.ago_min+m+L.ago_min_suffix;var h=Math.round(m/60);if(h<24)return L.ago_hours+h+L.ago_hours_suffix;return L.ago_days+Math.round(h/24)+L.ago_days_suffix})(dd.ts);if(confirm(L.draft_found+ago+L.draft_restore)){d.flow=dd.flow;if(dd.name)document.getElementById('bname').value=dd.name;useDraft=true}else{localStorage.removeItem('bot-draft-'+id)}}}
      }catch(ex){}
      if(d.flow){editor.import(d.flow);setTimeout(function(){popSelects();updStats();addAllNodeActions();upgradeLoadedNodes();updateAllSummaries();autoAlign()},200)}
      if(useDraft)markDirty();
      renderInboxes();
      document.getElementById('canvas-loading').classList.add('done');
    })
    .catch(function(err){
      document.getElementById('canvas-loading').classList.add('done');
      toast(L.load_err,'err');
    });
}

// ===== TOAST =====
var toastTimer=null;
function toast(m,t){
  clearTimeout(toastTimer);
  var el=document.getElementById('toast');
  // Note: icon HTML is static/safe, m is escaped via escHtml
  var icon=t==='err'?'<i class="ti ti-alert-circle" style="font-size:14px"></i> ':'<i class="ti ti-check" style="font-size:14px"></i> ';
  el.innerHTML=icon+escHtml(m);
  el.className='toast toast-'+(t||'ok')+' show';
  toastTimer=setTimeout(function(){el.classList.remove('show')},t==='err'?5000:3000);
}

// ===== UNSAVED CHANGES TRACKING =====
var hasUnsavedChanges = false;
var saveInd = document.getElementById('save-ind');
function markDirty(){
  if(!hasUnsavedChanges){hasUnsavedChanges=true;saveInd.textContent=isHe?'\u05E9\u05D9\u05E0\u05D5\u05D9\u05D9\u05DD \u05DC\u05D0 \u05E0\u05E9\u05DE\u05E8\u05D5':'Unsaved changes';saveInd.className='save-ind dirty'}
}
var lastSaveTime=null;
function markSaved(){
  hasUnsavedChanges=false;lastSaveTime=new Date();
  saveInd.textContent=isHe?'\u2713 \u05E0\u05E9\u05DE\u05E8':'\u2713 Saved';saveInd.className='save-ind saved';
  setTimeout(function(){if(!hasUnsavedChanges&&lastSaveTime){
    var diff=Math.floor((Date.now()-lastSaveTime.getTime())/60000);
    saveInd.textContent=diff<1?(isHe?'\u2713 \u05E0\u05E9\u05DE\u05E8':'\u2713 Saved'):(isHe?'\u05E0\u05E9\u05DE\u05E8 \u05DC\u05E4\u05E0\u05D9 '+diff+' \u05D3\u05E7\u05F3':'Saved '+diff+' min ago');
    saveInd.className='save-ind saved';
  }},5000);
}
window.addEventListener('beforeunload',function(e){if(hasUnsavedChanges){e.preventDefault();e.returnValue=''}});
// Auto-save draft to localStorage every 30s
setInterval(function(){
  if(!hasUnsavedChanges||!BOT_ID)return;
  try{
    localStorage.setItem('bot-draft-'+BOT_ID,JSON.stringify({flow:editor.export(),name:document.getElementById('bname').value,ts:Date.now()}));
    var si=document.getElementById('save-ind');
    if(si){si.textContent=L.draft_saved;si.className='save-ind saved';setTimeout(function(){if(hasUnsavedChanges){si.textContent=L.unsaved_changes;si.className='save-ind dirty'}},2000)}
  }catch(ex){toast(L.ls_full,'err')}
},30000);
editor.on('nodeCreated',function(){markDirty();pushUndo()});
editor.on('nodeRemoved',function(){markDirty();pushUndo()});
editor.on('connectionCreated',function(info){markDirty();pushUndo();addConnHitAreas();smartReposition(info)});
editor.on('connectionRemoved',function(){markDirty();pushUndo()});
// nodeMoved: single merged handler below (snap → undo → minimap)

// ===== UNDO STACK =====
var undoStack=[];
var redoStack=[];
var undoMax=100;
var isUndoing=false;
function updUndoState(){
  var ub=document.getElementById('undo-btn'),rb=document.getElementById('redo-btn');
  if(ub)ub.disabled=undoStack.length<2;
  if(rb)rb.disabled=redoStack.length===0;
}
function pushUndo(){
  if(isUndoing)return;
  var snap=JSON.stringify(editor.export());
  if(undoStack.length>0&&undoStack[undoStack.length-1]===snap)return;
  undoStack.push(snap);
  if(undoStack.length>undoMax)undoStack.shift();
  redoStack=[];
  updUndoState();
}
function undo(){
  if(undoStack.length<2)return;
  isUndoing=true;
  var cur=undoStack.pop();
  redoStack.push(cur);
  var prev=undoStack[undoStack.length-1];
  editor.import(JSON.parse(prev));
  setTimeout(function(){popSelects();updStats();isUndoing=false;updEmpty();upgradeLoadedNodes();updateAllSummaries();addConnHitAreas()},200);
  markDirty();updUndoState();
}
function redo(){
  if(!redoStack.length)return;
  isUndoing=true;
  var snap=redoStack.pop();
  undoStack.push(snap);
  editor.import(JSON.parse(snap));
  setTimeout(function(){popSelects();updStats();isUndoing=false;updEmpty();upgradeLoadedNodes();updateAllSummaries();addConnHitAreas()},200);
  markDirty();updUndoState();
}
// initial snapshot
setTimeout(function(){pushUndo()},500);

// ===== ZOOM TRACKING =====
function updZoom(){
  var pct=Math.round((editor.zoom||1)*100);
  document.getElementById('zoom-pct').textContent=pct+'%';
}
// Override zoom methods to track
var _zi=editor.zoom_in.bind(editor),_zo=editor.zoom_out.bind(editor),_zr=editor.zoom_reset.bind(editor);
editor.zoom_in=function(){_zi();updZoom()};
editor.zoom_out=function(){_zo();updZoom()};
editor.zoom_reset=function(){_zr();updZoom()};
// Track scroll-zoom
dfEl.addEventListener('wheel',function(){setTimeout(updZoom,50)});

// Add invisible wider hit-area paths to connections for easier clicking
function addConnHitAreas(){
  var paths=dfEl.querySelectorAll('.connection .main-path');
  for(var i=0;i<paths.length;i++){
    var p=paths[i];
    if(p.previousElementSibling&&p.previousElementSibling.classList.contains('hit-path'))continue;
    var hp=p.cloneNode(false);
    hp.setAttribute('class','hit-path');
    hp.style.cssText='stroke-width:16;stroke:transparent;fill:none;pointer-events:stroke;cursor:pointer;opacity:0';
    p.parentNode.insertBefore(hp,p);
    hp.addEventListener('click',function(ev){
      var mp=this.nextElementSibling;
      if(mp&&mp.classList.contains('main-path')){
        mp.dispatchEvent(new MouseEvent('click',{bubbles:true,clientX:ev.clientX,clientY:ev.clientY}));
      }
    });
  }
}
// Run on load + after undo/redo
setTimeout(addConnHitAreas,500);

function fitToScreen(){
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);if(!keys.length)return;
  var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];
    var el=document.querySelector('#node-'+keys[i]);
    var nw=el?el.offsetWidth:280,nodeH=el?el.offsetHeight:80;
    var x=n.pos_x,y=n.pos_y;
    if(x<minX)minX=x;if(y<minY)minY=y;
    if(x+nw>maxX)maxX=x+nw;if(y+nodeH>maxY)maxY=y+nodeH;
  }
  var cRect=document.querySelector('.canvas').getBoundingClientRect();
  var cW=cRect.width-60,cH=cRect.height-60;
  var fW=maxX-minX,fH=maxY-minY;
  if(fW<1||fH<1)return;
  var z=Math.min(cW/fW,cH/fH,1.5);
  z=Math.max(z,0.2);
  editor.zoom=z;
  editor.canvas_x=cW/2-((minX+maxX)/2)*z;
  editor.canvas_y=cH/2-((minY+maxY)/2)*z;
  editor.precanvas.style.transform='translate('+editor.canvas_x+'px, '+editor.canvas_y+'px) scale('+editor.zoom+')';
  updZoom();
}

// ===== KEYBOARD SHORTCUTS =====
function isInputFocused(){
  var t=document.activeElement;
  if(!t)return false;
  var tn=t.tagName.toLowerCase();
  return tn==='input'||tn==='textarea'||tn==='select'||t.isContentEditable;
}

document.addEventListener('keydown',function(e){
  // Ctrl+S: Save
  if((e.ctrlKey||e.metaKey)&&e.key==='s'){
    e.preventDefault();
    var sb=document.getElementById('savebtn');
    if(!sb.disabled)sb.click();
    return;
  }
  // Ctrl+Z: Undo, Ctrl+Shift+Z: Redo
  if((e.ctrlKey||e.metaKey)&&e.key==='z'){
    if(isInputFocused())return;
    e.preventDefault();
    if(e.shiftKey){redo()}else{undo()}
    return;
  }
  if((e.ctrlKey||e.metaKey)&&e.key==='y'){
    if(isInputFocused())return;
    e.preventDefault();
    redo();
    return;
  }
  // Ctrl+D: Duplicate selected node
  if((e.ctrlKey||e.metaKey)&&e.key==='d'){
    if(isInputFocused())return;
    e.preventDefault();
    duplicateSelected();
    return;
  }
  // Ctrl+C: Copy selected node
  if((e.ctrlKey||e.metaKey)&&e.key==='c'&&!isInputFocused()){
    e.preventDefault();
    var cid=getSelectedNodeId();if(!cid)return;
    var cnd=editor.getNodeFromId(cid);
    if(cnd){clipboard={name:cnd.name,data:JSON.parse(JSON.stringify(cnd.data)),pos_x:cnd.pos_x,pos_y:cnd.pos_y};toast(L.copied,'ok')}
    return;
  }
  // Ctrl+V: Paste copied node
  if((e.ctrlKey||e.metaKey)&&e.key==='v'&&!isInputFocused()){
    e.preventDefault();
    if(clipboard){
      var c=NC[clipboard.name];
      var pOff=Math.round(60/editor.zoom);
      if(c){
        editor.addNode(clipboard.name,c.i,c.o,clipboard.pos_x+pOff,clipboard.pos_y+pOff,clipboard.name,JSON.parse(JSON.stringify(clipboard.data)),nHtml(clipboard.name));
        setTimeout(popSelects,150);markDirty();pushUndo();
        toast(L.pasted,'ok');
      }
    }
    return;
  }
  if(isInputFocused())return;
  // Delete/Backspace: Delete selected connection or node
  if(e.key==='Delete'||e.key==='Backspace'){
    if(selectedConn){
      var connG=selectedConn.closest('.connection');
      if(connG){
        var nOut,nIn,oC,iC;
        connG.classList.forEach(function(c){
          if(c.startsWith('node_in_'))nIn=c.replace('node_in_node-','');
          if(c.startsWith('node_out_'))nOut=c.replace('node_out_node-','');
          if(c.startsWith('output_'))oC=c;
          if(c.startsWith('input_'))iC=c;
        });
        if(nOut&&nIn&&oC&&iC){editor.removeSingleConnection(nOut,nIn,oC,iC);markDirty();pushUndo()}
      }
      selectedConn=null;
      return;
    }
    deleteSelected();
    return;
  }
  // Arrow keys: Nudge selected node
  if(['ArrowUp','ArrowDown','ArrowLeft','ArrowRight'].includes(e.key)){
    var nid=getSelectedNodeId();if(!nid)return;
    e.preventDefault();
    var step=e.shiftKey?GRID:1;
    var nd=editor.getNodeFromId(nid);if(!nd)return;
    if(e.key==='ArrowLeft')nd.pos_x-=step;
    if(e.key==='ArrowRight')nd.pos_x+=step;
    if(e.key==='ArrowUp')nd.pos_y-=step;
    if(e.key==='ArrowDown')nd.pos_y+=step;
    var nel=document.getElementById('node-'+nid);
    if(nel){nel.style.left=nd.pos_x+'px';nel.style.top=nd.pos_y+'px';editor.updateConnectionNodes('node-'+nid)}
    markDirty();pushUndo();updateMinimap();
    return;
  }
  // F2: Open properties panel for selected node
  if(e.key==='F2'){
    var fid=getSelectedNodeId();if(!fid)return;
    e.preventDefault();openCfg();showNodeProps(fid);return;
  }
  // Escape: Close settings panel / Collapse all / Deselect
  if(e.key==='Escape'){
    if(sideCfg&&sideCfg.classList.contains('open')){closeCfg();return}
    collapseAllNodes();
    deselectAll();
    hideCtxMenu();
    // Update wires after collapse
    var allN=document.querySelectorAll('.drawflow-node');
    for(var ni=0;ni<allN.length;ni++){editor.updateConnectionNodes(allN[ni].id)}
    return;
  }
});

// ===== NODE SELECTION TRACKING =====
var selectedNodeId=null;
// nodeSelected/Unselected handled in SIDE-CFG OVERLAY section

function getSelectedNodeId(){
  if(selectedNodeId)return selectedNodeId;
  var sel=document.querySelector('.drawflow-node.selected');
  if(sel){var m=sel.id.match(/node-(\d+)/);if(m)return m[1]}
  return null;
}

function deleteSelected(){
  var id=getSelectedNodeId();
  if(id){deselectConn();editor.removeNodeId('node-'+id);selectedNodeId=null;hideNodeProps()}
}

function duplicateSelected(){
  var id=getSelectedNodeId();
  if(!id)return;
  duplicateNode(id);
}

function duplicateNode(id){
  var nd=editor.getNodeFromId(id);
  if(!nd)return;
  var c=NC[nd.name];if(!c)return;
  var newData=JSON.parse(JSON.stringify(nd.data));
  var newId=editor.addNode(nd.name,c.i,c.o,nd.pos_x+40,nd.pos_y+40,nd.name,newData,nHtml(nd.name));
  setTimeout(popSelects,150);
  markDirty();pushUndo();
  toast(L.node_duplicated,'ok');
  var newEl=document.getElementById('node-'+newId);
  if(newEl){newEl.classList.add('node-dup-pulse');setTimeout(function(){newEl.classList.remove('node-dup-pulse')},600)}
}

// ===== NODE SEARCH =====
document.getElementById('node-search').addEventListener('input',function(){
  var q=this.value.trim().toLowerCase();
  var secs=document.querySelectorAll('.side-nodes .sec');
  var totalVis=0;
  for(var s=0;s<secs.length;s++){
    var items=secs[s].querySelectorAll('.dn');
    var vis=0;
    for(var i=0;i<items.length;i++){
      var txt=items[i].textContent.toLowerCase();
      var ntype=items[i].getAttribute('data-node')||'';
      if(!q||txt.indexOf(q)!==-1||ntype.indexOf(q)!==-1){items[i].style.display='';vis++}
      else{items[i].style.display='none'}
    }
    secs[s].style.display=vis>0?'':'none';
    totalVis+=vis;
  }
  var noRes=document.getElementById('nodes-no-results');
  if(noRes)noRes.style.display=(q&&totalVis===0)?'block':'none';
});

// ===== PROPERTIES PANEL =====
var propsMeta={
  trigger:{icon:'<i class="ti ti-target"></i>',color:'#ff6b35',title:isHe?L.incoming_msg:'Incoming Message',fields:[
    {key:'trigger_type',label:isHe?L.trigger_type:'Trigger type',type:'select',opts:[['keyword',isHe?L.keyword:'Keyword'],['any',isHe?L.any_msg:'Any message'],['first',isHe?L.new_conv:'New conversation']]},
    {key:'keyword',label:isHe?L.keyword:'Keyword',type:'text',ph:isHe?L.enter_keyword:'Enter keyword...'}
  ]},
  message:{icon:'<i class="ti ti-message"></i>',color:'#4a9eff',title:isHe?L.send_msg:'Send Message',fields:[
    {key:'message',label:isHe?L.content:'Message content',type:'textarea',ph:isHe?L.type_msg:'Type a message...'}
  ]},
  image:{icon:'<i class="ti ti-photo"></i>',color:'#2ecc71',title:isHe?L.send_img:'Send Image',fields:[
    {key:'image_url',label:isHe?L.img_url:'Image URL',type:'text',ph:'https://...',dir:'ltr'},
    {key:'caption',label:isHe?L.caption:'Caption',type:'text',ph:isHe?L.optional:'Optional...'}
  ]},
  video:{icon:'<i class="ti ti-video"></i>',color:'#6c5ce7',title:isHe?L.send_vid:'Send Video',fields:[
    {key:'video_url',label:isHe?L.vid_url:'Video URL',type:'text',ph:'https://...',dir:'ltr'},
    {key:'caption',label:isHe?L.caption:'Caption',type:'text',ph:isHe?L.optional:'Optional...'}
  ]},
  buttons:{icon:'<i class="ti ti-click"></i>',color:'#00b894',title:isHe?L.buttons_title:'Buttons',fields:[
    {key:'body',label:isHe?L.msg_text:'Message text',type:'textarea',ph:isHe?L.type_msg:'Type a message...'},
    {key:'btn1',label:isHe?L.btn1:'Button 1',type:'text',ph:isHe?L.btn1:'Button 1'},
    {key:'btn2',label:isHe?L.btn2:'Button 2',type:'text',ph:isHe?L.btn2:'Button 2'},
    {key:'btn3',label:isHe?L.btn3:'Button 3',type:'text',ph:isHe?L.btn3:'Button 3'}
  ]},
  menu:{icon:'<i class="ti ti-list"></i>',color:'#9b59b6',title:isHe?L.menu_title:'Menu',fields:[
    {key:'title',label:isHe?L.title_label:'Title',type:'text',ph:isHe?L.choose_option:'Choose an option:'},
    {key:'opt1',label:isHe?L.opt+' 1':'Option 1',type:'text',ph:'1. ...'},
    {key:'opt2',label:isHe?L.opt+' 2':'Option 2',type:'text',ph:'2. ...'},
    {key:'opt3',label:isHe?L.opt+' 3':'Option 3',type:'text',ph:'3. ...'},
    {key:'opt4',label:isHe?L.opt+' 4':'Option 4',type:'text',ph:'4. ...'},
    {key:'opt5',label:isHe?L.opt+' 5':'Option 5',type:'text',ph:'5. ...'},
    {key:'opt6',label:isHe?L.opt+' 6':'Option 6',type:'text',ph:'6. ...'}
  ]},
  condition:{icon:'<i class="ti ti-git-branch"></i>',color:'#f1c40f',title:isHe?L.condition_title:'Condition',fields:[
    {key:'check_type',label:isHe?L.check_label:'Check type',type:'select',opts:[['contains',isHe?L.contains:'Contains'],['equals',isHe?L.equals:'Equals'],['regex','Regex'],['label_exists',isHe?L.label_exists:'Label exists'],['contact_type',isHe?L.contact_type:'Contact type'],['conversation_status',isHe?L.conv_status:'Conv. status'],['conversation_priority',isHe?L.conv_priority:'Conv. priority'],['has_label',isHe?L.conv_label:'Conv. label'],['custom_attribute',isHe?L.custom_attr:'Custom attribute'],['contact_field',isHe?L.contact_field:'Contact field']]},
    {key:'check_value',label:isHe?L.value_label:'Value',type:'cond_value',ph:'...'}
  ]},
  delay:{icon:'<i class="ti ti-clock-pause"></i>',color:'#8e44ad',title:isHe?L.delay_title:'Delay',fields:[
    {key:'seconds',label:isHe?L.seconds:'Seconds',type:'number',ph:'5'}
  ]},
  assign:{icon:'<i class="ti ti-user"></i>',color:'#27ae60',title:isHe?L.assign_title:'Assign to Agent',fields:[
    {key:'agent_id',label:isHe?L.agent:'Agent',type:'agent_select'},
    {key:'team_id',label:isHe?L.team:'Team',type:'team_select'}
  ]},
  add_label:{icon:'<i class="ti ti-tag"></i>',color:'#00b894',title:isHe?L.add_label_title:'Add Label',fields:[
    {key:'label_name',label:isHe?L.label_label:'Label',type:'label_select'}
  ]},
  remove_label:{icon:'<i class="ti ti-tag-off"></i>',color:'#00b894',title:isHe?L.remove_label_title:'Remove Label',fields:[
    {key:'label_name',label:isHe?L.label_label:'Label',type:'label_select'}
  ]},
  set_attribute:{icon:'<i class="ti ti-pencil"></i>',color:'#e67e22',title:isHe?L.set_attr_title:'Set Attribute',fields:[
    {key:'attr_key',label:isHe?L.attr_label:'Attribute',type:'custom_attr_select'},
    {key:'attr_value',label:isHe?L.value_label:'Value',type:'text',ph:'...'}
  ]},
  close:{icon:'<i class="ti ti-circle-check"></i>',color:'#e74c3c',title:isHe?L.close_title:'Close Conversation',fields:[]},
  webhook:{icon:'<i class="ti ti-webhook"></i>',color:'#3498db',title:'Webhook',fields:[
    {key:'url',label:'URL',type:'text',ph:'https://...',dir:'ltr'},
    {key:'method',label:isHe?'\u05DE\u05EA\u05D5\u05D3\u05D4':'Method',type:'select',opts:[['POST','POST'],['GET','GET']]},
    {key:'headers',label:isHe?'\u05DB\u05D5\u05EA\u05E8\u05D5\u05EA (JSON)':'Headers (JSON)',type:'textarea',ph:'{"Authorization":"Bearer ..."}',dir:'ltr'}
  ]},
  note:{icon:'<i class="ti ti-note"></i>',color:'#95a5a6',title:isHe?L.note_title:'Note',fields:[
    {key:'text',label:isHe?'\u05D4\u05E2\u05E8\u05D4 \u05E4\u05E0\u05D9\u05DE\u05D9\u05EA':'Internal note',type:'textarea',ph:'...'}
  ]},
  set_priority:{icon:'<i class="ti ti-flag"></i>',color:'#f1c40f',title:isHe?L.priority_title:'Conv. priority',fields:[
    {key:'priority',label:isHe?L.priority_label:'Priority',type:'select',opts:[['',isHe?L.select:'Select...'],['0',isHe?L.low:'Low'],['1',isHe?L.medium:'Medium'],['2',isHe?L.high:'High'],['3',isHe?L.urgent:'Urgent']]}
  ]},
  set_status:{icon:'<i class="ti ti-toggle-right"></i>',color:'#6366F1',title:isHe?L.status_title:'Conv. status',fields:[
    {key:'status',label:isHe?L.status_label:'Status',type:'select',opts:[['',isHe?L.select:'Select...'],['open',isHe?L.open:'Open'],['resolved',isHe?L.resolved:'Resolved'],['pending',isHe?L.pending:'Pending']]}
  ]},
  transfer_inbox:{icon:'<i class="ti ti-transfer"></i>',color:'#9b59b6',title:isHe?L.transfer_title:'Transfer Inbox',fields:[
    {key:'inbox_id',label:isHe?L.inbox_label:'Inbox',type:'inbox_select'}
  ]}
};

function showNodeProps(id){
  var nd=editor.getNodeFromId(id);
  if(!nd)return;
  var meta=propsMeta[nd.name];
  if(!meta)return;
  var pp=document.getElementById('props-panel');
  var tp=document.getElementById('tips-panel');
  tp.classList.add('hidden');
  var h='<div class="props-hdr"><div class="props-icon" style="background:'+meta.color+'33;color:'+meta.color+'">'+meta.icon+'</div><div><div class="props-title">'+meta.title+'</div><div class="props-type">'+nd.name+' #'+id+'</div></div></div>';
  for(var i=0;i<meta.fields.length;i++){
    var f=meta.fields[i];
    var val=nd.data[f.key]||'';
    h+='<div class="props-field"><label>'+f.label+'</label>';
    if(f.type==='textarea'){
      h+='<textarea data-pkey="'+f.key+'" placeholder="'+(f.ph||'')+'" rows="3">'+escHtml(val)+'</textarea>';
    } else if(f.type==='select'){
      h+='<select data-pkey="'+f.key+'">';
      for(var j=0;j<f.opts.length;j++){
        h+='<option value="'+f.opts[j][0]+'"'+(val===f.opts[j][0]?' selected':'')+'>'+f.opts[j][1]+'</option>';
      }
      h+='</select>';
    } else if(f.type==='agent_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">None</option>';
      for(var j=0;j<agents.length;j++){h+='<option value="'+agents[j].id+'"'+(String(val)===String(agents[j].id)?' selected':'')+'>'+escHtml(agents[j].name)+'</option>'}
      h+='</select>';
    } else if(f.type==='team_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">None</option>';
      for(var j=0;j<teams.length;j++){h+='<option value="'+teams[j].id+'"'+(String(val)===String(teams[j].id)?' selected':'')+'>'+escHtml(teams[j].name)+'</option>'}
      h+='</select>';
    } else if(f.type==='label_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">Select...</option>';
      for(var j=0;j<labels.length;j++){h+='<option value="'+escHtml(labels[j].title)+'"'+(val===labels[j].title?' selected':'')+'>'+escHtml(labels[j].title)+'</option>'}
      h+='</select>';
    } else if(f.type==='inbox_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">Select...</option>';
      for(var j=0;j<inboxes.length;j++){h+='<option value="'+inboxes[j].id+'"'+(String(val)===String(inboxes[j].id)?' selected':'')+'>'+escHtml(inboxes[j].name)+'</option>'}
      h+='</select>';
    } else if(f.type==='custom_attr_select'){
      h+='<select data-pkey="'+f.key+'"><option value="">select an attribute...</option>';
      var ca0=customAttrs.filter(function(a){return a.model===0||a.model==='contact_attribute'});
      var ca1=customAttrs.filter(function(a){return a.model===1||a.model==='conversation_attribute'});
      if(ca0.length){h+='<optgroup label="Contact">';for(var j=0;j<ca0.length;j++){h+='<option value="'+escHtml(ca0[j].key)+'"'+(val===ca0[j].key?' selected':'')+'>'+escHtml(ca0[j].name)+'</option>'}h+='</optgroup>'}
      if(ca1.length){h+='<optgroup label="Conversation">';for(var j=0;j<ca1.length;j++){h+='<option value="'+escHtml(ca1[j].key)+'"'+(val===ca1[j].key?' selected':'')+'>'+escHtml(ca1[j].name)+'</option>'}h+='</optgroup>'}
      h+='</select>';
    } else if(f.type==='cond_value'){
      // Dynamic value field based on check_type
      var ct=nd.data.check_type||'contains';
      h+=buildCondValueField(ct,val,nd.data.attr_key||'');
    } else {
      h+='<input type="'+(f.type||'text')+'" data-pkey="'+f.key+'" value="'+escHtml(val)+'" placeholder="'+(f.ph||'')+'"'+(f.dir?' style="direction:'+f.dir+'"':'')+'>';
    }
    h+='</div>';
  }
  h+='<button class="props-del" onclick="deleteSelected()"><i class="ti ti-trash" style="font-size:14px;vertical-align:middle"></i> '+(isHe?'\u05DE\u05D7\u05E7 \u05D0\u05DC\u05DE\u05E0\u05D8':'Delete node')+'</button>';
  pp.innerHTML=h;
  pp.classList.add('active');
  // Bind real-time sync
  var inputs=pp.querySelectorAll('[data-pkey]');
  for(var k=0;k<inputs.length;k++){
    (function(inp){
      var evType=(inp.tagName==='SELECT')?'change':'input';
      inp.addEventListener(evType,function(){
        var key=this.getAttribute('data-pkey');
        var nid=getSelectedNodeId();
        if(!nid)return;
        var nd=editor.getNodeFromId(nid);
        if(!nd)return;
        var merged=JSON.parse(JSON.stringify(nd.data));
        merged[key]=this.value;
        editor.updateNodeDataFromId(nid,merged);
        markDirty();
        updateNodeSummary(nid);
        // Debounced undo push for field edits
        clearTimeout(inp._undoTimer);
        inp._undoTimer=setTimeout(function(){pushUndo()},400);
        // If check_type changed, rebuild value field
        if(key==='check_type'&&nd.name==='condition'){
          merged.check_value='';merged.attr_key='';
          editor.updateNodeDataFromId(nid,merged);
          showNodeProps(nid);
        }
      });
    })(inputs[k]);
  }
}
function buildCondValueField(ct,val,attrKey){
  var h='';
  var _sel=isHe?L.select:'Select...';
  switch(ct){
    case 'contact_type':
      h+='<select data-pkey="check_value"><option value="">'+_sel+'</option>';
      h+='<option value="0"'+(val==='0'?' selected':'')+'>'+(isHe?'\u05DE\u05D1\u05E7\u05E8':'Visitor')+'</option>';
      h+='<option value="1"'+(val==='1'?' selected':'')+'>'+(isHe?'\u05DC\u05D9\u05D3':'Lead')+'</option>';
      h+='<option value="2"'+(val==='2'?' selected':'')+'>'+(isHe?'\u05DC\u05E7\u05D5\u05D7':'Customer')+'</option>';
      h+='</select>';break;
    case 'conversation_status':
      h+='<select data-pkey="check_value"><option value="">'+_sel+'</option>';
      h+='<option value="open"'+(val==='open'?' selected':'')+'>'+(isHe?L.open:'Open')+'</option>';
      h+='<option value="resolved"'+(val==='resolved'?' selected':'')+'>'+(isHe?L.resolved:'Resolved')+'</option>';
      h+='<option value="pending"'+(val==='pending'?' selected':'')+'>'+(isHe?L.pending:'Pending')+'</option>';
      h+='<option value="snoozed"'+(val==='snoozed'?' selected':'')+'>'+(isHe?'\u05D1\u05D4\u05E9\u05D4\u05D9\u05D4':'Snoozed')+'</option>';
      h+='</select>';break;
    case 'conversation_priority':
      h+='<select data-pkey="check_value"><option value="">'+_sel+'</option>';
      h+='<option value="0"'+(val==='0'?' selected':'')+'>'+(isHe?L.low:'Low')+'</option>';
      h+='<option value="1"'+(val==='1'?' selected':'')+'>'+(isHe?L.medium:'Medium')+'</option>';
      h+='<option value="2"'+(val==='2'?' selected':'')+'>'+(isHe?L.high:'High')+'</option>';
      h+='<option value="3"'+(val==='3'?' selected':'')+'>'+(isHe?L.urgent:'Urgent')+'</option>';
      h+='</select>';break;
    case 'has_label':
      h+='<select data-pkey="check_value"><option value="">'+(isHe?'\u05D1\u05D7\u05E8 \u05EA\u05D2\u05D9\u05EA...':'Select label...')+'</option>';
      for(var j=0;j<labels.length;j++){h+='<option value="'+escHtml(labels[j].title)+'"'+(val===labels[j].title?' selected':'')+'>'+escHtml(labels[j].title)+'</option>'}
      h+='</select>';break;
    case 'custom_attribute':
      h+='<div class="cond-sub"><label>'+(isHe?L.attr_label:'Attribute')+'</label><select data-pkey="attr_key"><option value="">'+(isHe?'\u05D1\u05D7\u05E8 \u05DE\u05D0\u05E4\u05D9\u05D9\u05DF...':'select an attribute...')+'</option>';
      if(typeof customAttrs!=='undefined'){
        var contactAttrs=customAttrs.filter(function(a){return a.model===0||a.model==='contact_attribute'});
        var convAttrs=customAttrs.filter(function(a){return a.model===1||a.model==='conversation_attribute'});
        if(contactAttrs.length){h+='<optgroup label="'+(isHe?'\u05D0\u05D9\u05E9 \u05E7\u05E9\u05E8':'Contact')+'">';for(var j=0;j<contactAttrs.length;j++){h+='<option value="'+escHtml(contactAttrs[j].key)+'"'+(attrKey===contactAttrs[j].key?' selected':'')+'>'+escHtml(contactAttrs[j].name)+'</option>'}h+='</optgroup>'}
        if(convAttrs.length){h+='<optgroup label="'+(isHe?'\u05E9\u05D9\u05D7\u05D4':'Conversation')+'">';for(var j=0;j<convAttrs.length;j++){h+='<option value="'+escHtml(convAttrs[j].key)+'"'+(attrKey===convAttrs[j].key?' selected':'')+'>'+escHtml(convAttrs[j].name)+'</option>'}h+='</optgroup>'}
      }
      h+='</select></div>';
      h+='<div class="cond-sub"><label>'+(isHe?L.value_label:'Value')+'</label><input type="text" data-pkey="check_value" value="'+escHtml(val)+'" placeholder="..."></div>';
      break;
    case 'contact_field':
      h+='<div class="cond-sub"><label>'+(isHe?'\u05E9\u05D3\u05D4':'Field')+'</label><select data-pkey="attr_key"><option value="">'+(isHe?'\u05D1\u05D7\u05E8 \u05E9\u05D3\u05D4...':'Select field...')+'</option>';
      if(typeof contactFields!=='undefined'){for(var j=0;j<contactFields.length;j++){h+='<option value="'+escHtml(contactFields[j].key)+'"'+(attrKey===contactFields[j].key?' selected':'')+'>'+escHtml(contactFields[j].label)+'</option>'}}
      h+='</select></div>';
      h+='<div class="cond-sub"><label>'+(isHe?L.value_label:'Value')+'</label><input type="text" data-pkey="check_value" value="'+escHtml(val)+'" placeholder="..."></div>';
      break;
    default:
      h+='<input type="text" data-pkey="check_value" value="'+escHtml(val)+'" placeholder="...">';
  }
  return h;
}

function hideNodeProps(){
  document.getElementById('props-panel').classList.remove('active');
  document.getElementById('props-panel').innerHTML='';
  document.getElementById('tips-panel').classList.remove('hidden');
}
function deselectAll(){
  selectedNodeId=null;
  var sels=document.querySelectorAll('.drawflow-node.selected');
  for(var i=0;i<sels.length;i++)sels[i].classList.remove('selected');
  hideNodeProps();
  selectedNodeType=null;clearNodeSelection();
}
function escHtml(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;')}

// ===== CONTEXT MENU =====
var ctxMenu=document.getElementById('ctx-menu');
var ctxNodeId=null;
var clipboard=null;
var ctxPastePos=null;

dfEl.addEventListener('contextmenu',function(e){
  e.preventDefault();
  var nEl=e.target.closest('.drawflow-node');
  ctxPastePos=null;
  if(!nEl){
    // Canvas right-click: show paste-only menu if clipboard has content
    if(!clipboard){hideCtxMenu();return}
    ctxNodeId=null;
    ctxMenu.querySelectorAll('[data-act="duplicate"],[data-act="copy"]').forEach(function(el){el.style.display='none'});
    ctxMenu.querySelector('.ctx-del').style.display='none';
    ctxMenu.querySelector('.ctx-sep').style.display='none';
    ctxPastePos={x:e.clientX,y:e.clientY};
  } else {
    // Node right-click: show full menu
    var m=nEl.id.match(/node-(\d+)/);
    ctxNodeId=m?m[1]:null;
    ctxMenu.querySelectorAll('.ctx-item,.ctx-sep').forEach(function(el){el.style.display=''});
  }
  // Toggle paste disabled state
  var pasteItem=ctxMenu.querySelector('[data-act="paste"]');
  if(pasteItem)pasteItem.classList.toggle('ctx-disabled',!clipboard);
  ctxMenu.style.left=e.clientX+'px';
  ctxMenu.style.top=e.clientY+'px';
  ctxMenu.classList.add('open');
  // Adjust if off-screen
  var r=ctxMenu.getBoundingClientRect();
  if(r.right>window.innerWidth)ctxMenu.style.left=(e.clientX-r.width)+'px';
  if(r.bottom>window.innerHeight)ctxMenu.style.top=(e.clientY-r.height)+'px';
});

ctxMenu.addEventListener('click',function(e){
  var item=e.target.closest('[data-act]');
  if(!item)return;
  var act=item.getAttribute('data-act');
  if(act==='duplicate'&&ctxNodeId)duplicateNode(ctxNodeId);
  if(act==='copy'&&ctxNodeId){
    var nd=editor.getNodeFromId(ctxNodeId);
    if(nd)clipboard={name:nd.name,data:JSON.parse(JSON.stringify(nd.data)),pos_x:nd.pos_x,pos_y:nd.pos_y};
    toast('Copied','ok');
  }
  if(act==='paste'&&clipboard){
    var c=NC[clipboard.name];if(c){
      var px,py;
      if(ctxPastePos){
        var rect=editor.precanvas.getBoundingClientRect();
        px=(ctxPastePos.x-rect.x)/editor.zoom;
        py=(ctxPastePos.y-rect.y)/editor.zoom;
      } else {
        var pOff2=Math.round(60/editor.zoom);
        px=clipboard.pos_x+pOff2;py=clipboard.pos_y+pOff2;
      }
      editor.addNode(clipboard.name,c.i,c.o,px,py,clipboard.name,JSON.parse(JSON.stringify(clipboard.data)),nHtml(clipboard.name));
      setTimeout(popSelects,150);markDirty();pushUndo();
    }
  }
  if(act==='delete'&&ctxNodeId){deselectConn();editor.removeNodeId('node-'+ctxNodeId);selectedNodeId=null;hideNodeProps();markDirty()}
  hideCtxMenu();
});

document.addEventListener('click',function(e){
  if(!ctxMenu.contains(e.target))hideCtxMenu();
});
function hideCtxMenu(){ctxMenu.classList.remove('open');ctxNodeId=null}

// ===== DROP ZONE FEEDBACK =====
var canvasEl=document.querySelector('.canvas');
canvasEl.addEventListener('dragenter',function(e){if(dragNodeType)canvasEl.classList.add('drop-hover')});
canvasEl.addEventListener('dragleave',function(e){
  if(!canvasEl.contains(e.relatedTarget))canvasEl.classList.remove('drop-hover');
});
canvasEl.addEventListener('drop',function(){canvasEl.classList.remove('drop-hover')});

// ===== AUTO-ALIGN =====
function collapseAllNodes(){
  var nodes=document.querySelectorAll('.drawflow-node');
  for(var i=0;i<nodes.length;i++){
    var nb=nodes[i].querySelector('.nb-collapsible');
    var toggle=nodes[i].querySelector('.nh-toggle');
    if(nb&&nb.classList.contains('nb-open')){
      nb.classList.remove('nb-open');
      if(toggle)toggle.classList.remove('open');
      var m=nodes[i].id.match(/node-(\d+)/);
      if(m)updateNodeSummary(m[1]);
    }
  }
}
// === Smart auto-reposition on connection (ManyChat-style) ===
function smartReposition(info){
  // Drawflow connectionCreated: {output_id:NUM, input_id:NUM, output_class:STR, input_class:STR}
  if(!info||!info.output_id||!info.input_id)return;
  var srcId=String(info.output_id);
  var tgtId=String(info.input_id);
  var srcEl=document.getElementById('node-'+srcId);
  var tgtEl=document.getElementById('node-'+tgtId);
  if(!srcEl||!tgtEl)return;
  var d=editor.export().drawflow.Home.data;
  var srcN=d[srcId];var tgtN=d[tgtId];
  if(!srcN||!tgtN)return;
  var srcW=srcEl.offsetWidth;var tgtW=tgtEl.offsetWidth;
  var srcH=srcEl.offsetHeight;var tgtH=tgtEl.offsetHeight;
  // Only reposition if target is to the LEFT of source or overlapping
  var needsMove=tgtN.pos_x < srcN.pos_x+srcW+80;
  // Also check if target was just created (close to default/drop position)
  var tgtAge=Date.now()-(tgtEl._createdAt||0);
  if(!needsMove && tgtAge>2000) return; // already positioned manually, don't touch
  // Calculate ideal position: to the right of source, vertically centered
  var idealX=srcN.pos_x+srcW+200;
  var idealY=srcN.pos_y;
  // Find which output port this connection uses
  var outClass=info.output_class||'output_1';
  var outIdx=parseInt(outClass.replace('output_',''))||1;
  var totalOuts=Object.keys(srcN.outputs||{}).length;
  if(totalOuts>1){
    // Spread branches vertically: center output → same Y, top → up, bottom → down
    var spread=80;
    var mid=(totalOuts+1)/2;
    idealY=srcN.pos_y + (outIdx-mid)*spread;
  }
  // Check for overlap with existing nodes
  for(var nid in d){
    if(nid===tgtId)continue;
    var nx=d[nid].pos_x;var ny=d[nid].pos_y;
    var ne=document.getElementById('node-'+nid);
    if(!ne)continue;
    var nw=ne.offsetWidth;var nh=ne.offsetHeight;
    // If overlapping, nudge down
    if(idealX<nx+nw+20 && idealX+tgtW+20>nx && idealY<ny+nh+20 && idealY+tgtH+20>ny){
      idealY=ny+nh+40;
    }
  }
  // Apply position
  editor.drawflow.drawflow.Home.data[tgtId].pos_x=idealX;
  editor.drawflow.drawflow.Home.data[tgtId].pos_y=Math.max(20,idealY);
  tgtEl.style.left=idealX+'px';
  tgtEl.style.top=Math.max(20,idealY)+'px';
  // Update connections
  editor.updateConnectionNodes('node-'+srcId);
  editor.updateConnectionNodes('node-'+tgtId);
}

function autoAlign(){
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);if(!keys.length)return;
  // Collapse all nodes first for consistent sizing
  collapseAllNodes();
  setTimeout(function(){_doAutoAlign()},300);
}
function _doAutoAlign(){
  // === ManyChat-style auto layout ===
  var data=editor.export();
  var d=data.drawflow.Home.data;
  var keys=Object.keys(d);if(!keys.length)return;

  // Build undirected adjacency for component detection
  var adj={};
  for(var i=0;i<keys.length;i++)adj[keys[i]]=[];
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];
    for(var o in n.outputs){
      var cs=(n.outputs[o].connections||[]);
      for(var c=0;c<cs.length;c++){
        adj[keys[i]].push(cs[c].node);
        if(adj[cs[c].node])adj[cs[c].node].push(keys[i]);
      }
    }
  }

  // BFS to find connected components
  var visited={};var components=[];
  for(var i=0;i<keys.length;i++){
    if(visited[keys[i]])continue;
    var comp=[];var q=[keys[i]];visited[keys[i]]=true;
    while(q.length){
      var cur=q.shift();comp.push(cur);
      for(var j=0;j<(adj[cur]||[]).length;j++){
        var nb=adj[cur][j];
        if(!visited[nb]){visited[nb]=true;q.push(nb)}
      }
    }
    components.push(comp);
  }

  // Sort: trigger-containing components first, then larger first
  components.sort(function(a,b){
    var at=a.some(function(id){return d[id].name==='trigger'});
    var bt=b.some(function(id){return d[id].name==='trigger'});
    if(at!==bt)return at?-1:1;
    return b.length-a.length;
  });

  // Separate multi-node trees from single orphans
  var trees=[];var orphans=[];
  for(var i=0;i<components.length;i++){
    if(components[i].length===1)orphans.push(components[i][0]);
    else trees.push(components[i]);
  }

  // Layout each tree with dagre
  function layoutTree(comp){
    var g=new dagre.graphlib.Graph();
    g.setGraph({rankdir:'LR',nodesep:60,ranksep:200,marginx:0,marginy:0,ranker:'network-simplex'});
    g.setDefaultEdgeLabel(function(){return{}});
    for(var ni=0;ni<comp.length;ni++){
      var el=document.getElementById('node-'+comp[ni]);
      g.setNode(comp[ni],{width:el?el.offsetWidth:220,height:el?el.offsetHeight:100});
    }
    for(var ni=0;ni<comp.length;ni++){
      var n=d[comp[ni]];
      for(var o in n.outputs){
        var cs=(n.outputs[o].connections||[]);
        for(var c=0;c<cs.length;c++){g.setEdge(comp[ni],cs[c].node)}
      }
    }
    dagre.layout(g);
    var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
    var nodes=[];
    g.nodes().forEach(function(nid){
      var dn=g.node(nid);
      var lx=dn.x-dn.width/2;var ly=dn.y-dn.height/2;
      nodes.push({id:nid,x:lx,y:ly,w:dn.width,h:dn.height});
      minX=Math.min(minX,lx);minY=Math.min(minY,ly);
      maxX=Math.max(maxX,lx+dn.width);maxY=Math.max(maxY,ly+dn.height);
    });
    for(var ni=0;ni<nodes.length;ni++){nodes[ni].x-=minX;nodes[ni].y-=minY}
    return{nodes:nodes,width:maxX-minX,height:maxY-minY};
  }

  var treeLayouts=[];
  for(var ti=0;ti<trees.length;ti++)treeLayouts.push(layoutTree(trees[ti]));

  // Place trees stacked vertically (LR layout: each tree flows left→right)
  var TREE_GAP=120;
  var ORPHAN_GAP=50;
  var startX=100;var startY=80;
  var curY=startY;var maxTreeW=0;

  for(var ti=0;ti<treeLayouts.length;ti++){
    var lay=treeLayouts[ti];
    for(var ni=0;ni<lay.nodes.length;ni++){
      var nd=lay.nodes[ni];
      var x=Math.round(startX+nd.x);var y=Math.round(curY+nd.y);
      editor.drawflow.drawflow.Home.data[nd.id].pos_x=x;
      editor.drawflow.drawflow.Home.data[nd.id].pos_y=y;
      var el=document.getElementById('node-'+nd.id);
      if(el){el.style.left=x+'px';el.style.top=y+'px'}
    }
    maxTreeW=Math.max(maxTreeW,lay.width);
    curY+=lay.height+TREE_GAP;
  }

  // Place orphans in a column below the trees
  if(orphans.length){
    var orphY=curY+(treeLayouts.length?40:0);
    var orphX=startX;
    var maxRowH=0;var cols=Math.min(orphans.length,3);
    for(var oi=0;oi<orphans.length;oi++){
      var nid=orphans[oi];
      var el=document.getElementById('node-'+nid);
      var w=el?el.offsetWidth:220;var h=el?el.offsetHeight:100;
      editor.drawflow.drawflow.Home.data[nid].pos_x=orphX;
      editor.drawflow.drawflow.Home.data[nid].pos_y=orphY;
      if(el){el.style.left=orphX+'px';el.style.top=orphY+'px'}
      maxRowH=Math.max(maxRowH,h);
      orphX+=w+ORPHAN_GAP;
      if((oi+1)%cols===0){orphX=startX;orphY+=maxRowH+ORPHAN_GAP;maxRowH=0}
    }
  }

  // Update all connections
  var allNodes=document.querySelectorAll('.drawflow-node');
  for(var ni=0;ni<allNodes.length;ni++){editor.updateConnectionNodes(allNodes[ni].id)}
  pushUndo();fitToScreen();
  markDirty();
  toast('Nodes aligned','ok');
}

// ===== FLOW VALIDATION =====
function validateFlow(){
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);
  var issues=[];
  // Clear previous highlights
  var prev=document.querySelectorAll('.node-error');
  for(var p=0;p<prev.length;p++)prev[p].classList.remove('node-error');

  if(!keys.length){issues.push({msg:isHe?'\u05D0\u05D9\u05DF \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD \u2014 \u05D2\u05E8\u05D5\u05E8 \u05D8\u05E8\u05D9\u05D2\u05E8 \u05DE\u05D4\u05E4\u05DC\u05D8\u05D4':'No nodes \u2014 drag a trigger from the palette',id:null});showIssues(issues);return}
  // Check for trigger
  var hasTrigger=false;
  for(var i=0;i<keys.length;i++){if(d[keys[i]].name==='trigger')hasTrigger=true}
  if(!hasTrigger)issues.push({msg:isHe?'\u05D7\u05E1\u05E8 \u05D8\u05E8\u05D9\u05D2\u05E8 \u2014 \u05D2\u05E8\u05D5\u05E8 "\u05D4\u05D5\u05D3\u05E2\u05D4 \u05E0\u05DB\u05E0\u05E1\u05EA" \u05DE\u05D4\u05E4\u05DC\u05D8\u05D4':'Missing trigger \u2014 drag "Incoming Message" from the palette',id:null});
  // Check each node
  var hasIncoming={};
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];
    for(var o in n.outputs){(n.outputs[o].connections||[]).forEach(function(c){hasIncoming[c.node]=true})}
  }
  for(var i=0;i<keys.length;i++){
    var n=d[keys[i]];var nid=keys[i];
    // Orphan check (not trigger/note, no incoming)
    if(n.name!=='trigger'&&n.name!=='note'&&!hasIncoming[nid]){
      issues.push({msg:nodeName(n.name)+' #'+nid+(isHe?' \u05DE\u05E0\u05D5\u05EA\u05E7 \u2014 \u05D7\u05D1\u05E8 \u05DC\u05D0\u05DC\u05DE\u05E0\u05D8 \u05E7\u05D5\u05D3\u05DD':' disconnected \u2014 connect to a previous node'),id:nid});
    }
    // Empty required fields
    if(n.name==='message'&&!n.data.message){issues.push({msg:(isHe?'\u05D4\u05D5\u05D3\u05E2\u05D4 \u05E8\u05D9\u05E7\u05D4':'Empty message')+' #'+nid+(isHe?' \u2014 \u05D4\u05D5\u05E1\u05E3 \u05D8\u05E7\u05E1\u05D8':' \u2014 add text'),id:nid})}
    if(n.name==='trigger'&&n.data.trigger_type==='keyword'&&!n.data.keyword){issues.push({msg:(isHe?'\u05DE\u05D9\u05DC\u05EA \u05DE\u05E4\u05EA\u05D7 \u05E8\u05D9\u05E7\u05D4':'Empty keyword')+' #'+nid+(isHe?' \u2014 \u05D4\u05D6\u05DF \u05DE\u05D9\u05DC\u05EA \u05DE\u05E4\u05EA\u05D7':' \u2014 enter a trigger keyword'),id:nid})}
    if(n.name==='menu'&&!n.data.opt1){issues.push({msg:(isHe?'\u05EA\u05E4\u05E8\u05D9\u05D8':'Menu')+' #'+nid+(isHe?' \u05DC\u05DC\u05D0 \u05D0\u05E4\u05E9\u05E8\u05D5\u05D9\u05D5\u05EA \u2014 \u05D4\u05D5\u05E1\u05E3 \u05DC\u05E4\u05D7\u05D5\u05EA \u05D0\u05D7\u05EA':' no options \u2014 add at least one'),id:nid})}
    if(n.name==='webhook'&&!n.data.url){issues.push({msg:'Webhook #'+nid+(isHe?' \u05DC\u05DC\u05D0 URL \u2014 \u05D4\u05D6\u05DF \u05DB\u05EA\u05D5\u05D1\u05EA':' no URL \u2014 enter a URL'),id:nid})}
    if(n.name==='set_priority'&&!n.data.priority&&n.data.priority!=='0'){issues.push({msg:(isHe?'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA':'Priority')+' #'+nid+(isHe?' \u05DC\u05D0 \u05E0\u05D1\u05D7\u05E8\u05D4 \u2014 \u05D1\u05D7\u05E8 \u05E8\u05DE\u05D4':' not selected \u2014 select a level'),id:nid})}
    if(n.name==='set_status'&&!n.data.status){issues.push({msg:(isHe?'\u05E1\u05D8\u05D8\u05D5\u05E1':'Status')+' #'+nid+(isHe?' \u05DC\u05D0 \u05E0\u05D1\u05D7\u05E8 \u2014 \u05D1\u05D7\u05E8 \u05E2\u05E8\u05DA':' not selected \u2014 select a value'),id:nid})}
    if(n.name==='transfer_inbox'&&!n.data.inbox_id){issues.push({msg:(isHe?'\u05D4\u05E2\u05D1\u05E8\u05D4':'Transfer')+' #'+nid+(isHe?' \u05DC\u05DC\u05D0 \u05EA\u05D9\u05D1\u05D4 \u2014 \u05D1\u05D7\u05E8 \u05D9\u05E2\u05D3':' no inbox \u2014 select a target'),id:nid})}
    if(n.name==='buttons'&&!n.data.btn1){issues.push({msg:(isHe?'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD':'Buttons')+' #'+nid+(isHe?' \u2014 \u05D4\u05D5\u05E1\u05E3 \u05DB\u05E4\u05EA\u05D5\u05E8 \u05E8\u05D0\u05E9\u05D5\u05DF':' \u2014 add a first button'),id:nid})}
    if(n.name==='image'&&!n.data.image_url){issues.push({msg:(isHe?'\u05EA\u05DE\u05D5\u05E0\u05D4':'Image')+' #'+nid+(isHe?' \u05DC\u05DC\u05D0 URL \u2014 \u05D4\u05D5\u05E1\u05E3 \u05E7\u05D9\u05E9\u05D5\u05E8':' no URL \u2014 add a link'),id:nid})}
    if(n.name==='video'&&!n.data.video_url){issues.push({msg:(isHe?'\u05D5\u05D9\u05D3\u05D0\u05D5':'Video')+' #'+nid+(isHe?' \u05DC\u05DC\u05D0 URL \u2014 \u05D4\u05D5\u05E1\u05E3 \u05E7\u05D9\u05E9\u05D5\u05E8':' no URL \u2014 add a link'),id:nid})}
    if(n.name==='assign'&&!n.data.agent_id&&!n.data.team_id){issues.push({msg:(isHe?'\u05D4\u05E7\u05E6\u05D4':'Assign')+' #'+nid+(isHe?' \u2014 \u05D1\u05D7\u05E8 \u05E0\u05E6\u05D9\u05D2 \u05D0\u05D5 \u05E6\u05D5\u05D5\u05EA':' \u2014 select an agent or team'),id:nid})}
    if(n.name==='set_attribute'&&!n.data.attr_key){issues.push({msg:(isHe?'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':'Attribute')+' #'+nid+(isHe?' \u05DC\u05DC\u05D0 \u05E9\u05DD \u2014 \u05D1\u05D7\u05E8 \u05DE\u05D0\u05E4\u05D9\u05D9\u05DF':' no name \u2014 select an attribute'),id:nid})}
    // No outputs connected (except close/note)
    if(n.name!=='close'&&n.name!=='note'){
      var totalConn=0;
      for(var o in n.outputs){totalConn+=(n.outputs[o].connections||[]).length}
      if(totalConn===0&&n.name!=='trigger'){issues.push({msg:nodeName(n.name)+' #'+nid+(isHe?' \u05DC\u05DC\u05D0 \u05D7\u05D9\u05D1\u05D5\u05E8 \u2014 \u05D7\u05D1\u05E8 \u05DC\u05D9\u05E2\u05D3':' no connection \u2014 connect to a target'),id:nid})}
    }
  }
  showIssues(issues);
  if(!issues.length)toast(isHe?'\u05D4\u05D6\u05E8\u05D9\u05DE\u05D4 \u05EA\u05E7\u05D9\u05E0\u05D4!':'Flow is valid!','ok');
}

function nodeName(t){
  if(isHe){var m={trigger:'\u05D8\u05E8\u05D9\u05D2\u05E8',message:'\u05D4\u05D5\u05D3\u05E2\u05D4',image:'\u05EA\u05DE\u05D5\u05E0\u05D4',video:'\u05D5\u05D9\u05D3\u05D0\u05D5',buttons:'\u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD',menu:'\u05EA\u05E4\u05E8\u05D9\u05D8',condition:'\u05EA\u05E0\u05D0\u05D9',delay:'\u05D4\u05DE\u05EA\u05E0\u05D4',assign:'\u05D4\u05E7\u05E6\u05D4',add_label:'\u05EA\u05D2\u05D9\u05EA+',remove_label:'\u05EA\u05D2\u05D9\u05EA-',set_attribute:'\u05DE\u05D0\u05E4\u05D9\u05D9\u05DF',close:'\u05E1\u05D2\u05D5\u05E8',webhook:'Webhook',note:'\u05D4\u05E2\u05E8\u05D4',set_priority:'\u05E2\u05D3\u05D9\u05E4\u05D5\u05EA',set_status:'\u05E1\u05D8\u05D8\u05D5\u05E1',transfer_inbox:'\u05D4\u05E2\u05D1\u05E8\u05D4'};return m[t]||t}
  var m={trigger:'Trigger',message:'Message',image:'Image',video:'Video',buttons:'Buttons',menu:'Menu',condition:'Condition',delay:'Delay',assign:'Assign',add_label:'Label+',remove_label:'Label-',set_attribute:'Attribute',close:'Close',webhook:'Webhook',note:'Note',set_priority:'Priority',set_status:'Status',transfer_inbox:'Transfer'};
  return m[t]||t;
}

function showIssues(issues){
  var vp=document.getElementById('valid-panel');
  var vl=document.getElementById('valid-list');
  if(!issues.length){vp.style.display='none';return}
  vp.style.display='block';
  openCfg();
  vl.innerHTML='';
  for(var i=0;i<issues.length;i++){
    (function(issue){
      var el=document.createElement('div');
      el.className='valid-item';
      el.innerHTML='<i class="ti ti-alert-triangle" style="font-size:12px"></i> '+issue.msg;
      if(issue.id){
        // Highlight the node
        var ne=document.getElementById('node-'+issue.id);
        if(ne)ne.classList.add('node-error');
        el.addEventListener('click',function(){
          // Center viewport on node
          var ne2=document.getElementById('node-'+issue.id);
          if(ne2){
            ne2.classList.add('selected');
            var nd=editor.getNodeFromId(issue.id);
            if(nd){
              var dRect=document.getElementById('drawflow').getBoundingClientRect();
              editor.canvas_x=dRect.width/2-nd.pos_x*editor.zoom;
              editor.canvas_y=dRect.height/2-nd.pos_y*editor.zoom;
              editor.precanvas.style.transform='translate('+editor.canvas_x+'px,'+editor.canvas_y+'px) scale('+editor.zoom+')';
              if(typeof updateMinimap==='function')updateMinimap();
            }
          }
        });
      }
      vl.appendChild(el);
    })(issues[i]);
  }
}

// markSaved is called directly in the save handler above

// ===== COLLAPSIBLE PALETTE TOGGLE =====
var sideNodes=document.getElementById('side-nodes');
var nodesToggle=document.getElementById('nodes-toggle');
// Restore saved state
if(localStorage.getItem('bb-palette-expanded')==='true')sideNodes.classList.add('expanded');
nodesToggle.addEventListener('click',function(){
  sideNodes.classList.toggle('expanded');
  localStorage.setItem('bb-palette-expanded',sideNodes.classList.contains('expanded'));
});

// ===== SIDE-CFG OVERLAY =====
var sideCfg=document.getElementById('side-cfg');
var sideCfgClose=document.getElementById('side-cfg-close');
function openCfg(){sideCfg.classList.add('open');try{localStorage.setItem('bb-cfg-open','1')}catch(ex){}}
function closeCfg(){sideCfg.classList.remove('open');try{localStorage.removeItem('bb-cfg-open')}catch(ex){}}
sideCfgClose.addEventListener('click',closeCfg);
// Click outside to close
document.addEventListener('click',function(e){
  if(!sideCfg.classList.contains('open'))return;
  if(sideCfg.contains(e.target))return;
  if(e.target.closest&&e.target.closest('.drawflow-node'))return;
  if(e.target.closest&&e.target.closest('.tbtn'))return;
  closeCfg();
});
// Track selection + auto-expand on select, auto-collapse on deselect
editor.on('nodeSelected',function(id){
  selectedNodeId=id;
  // Collapse any other open node first
  var nodes=document.querySelectorAll('.drawflow-node');
  for(var i=0;i<nodes.length;i++){
    var nid=nodes[i].id;
    if(nid==='node-'+id)continue;
    var nb2=nodes[i].querySelector('.nb-collapsible');
    var tog2=nodes[i].querySelector('.nh-toggle');
    if(nb2&&nb2.classList.contains('nb-open')){
      nb2.classList.remove('nb-open');
      if(tog2)tog2.classList.remove('open');
      var mid=nodes[i].id.match(/node-(\d+)/);
      if(mid)updateNodeSummary(mid[1]);
      editor.updateConnectionNodes(nid);
    }
  }
  // Expand selected node
  var el=document.getElementById('node-'+id);
  if(el){
    var nb=el.querySelector('.nb-collapsible');
    var toggle=el.querySelector('.nh-toggle');
    if(nb&&!nb.classList.contains('nb-open')){
      nb.classList.add('nb-open');
      if(toggle)toggle.classList.add('open');
      var iv4=setInterval(function(){editor.updateConnectionNodes(el.id)},30);
      var done4=false;
      var finish4=function(){if(done4)return;done4=true;clearInterval(iv4);editor.updateConnectionNodes(el.id)};
      nb.addEventListener('transitionend',function h4(e){if(e.propertyName==='max-height'){nb.removeEventListener('transitionend',h4);finish4()}});
      setTimeout(finish4,320);
    }
  }
});
editor.on('nodeUnselected',function(){
  selectedNodeId=null;
  // Collapse all open nodes when clicking empty canvas
  var nodes=document.querySelectorAll('.drawflow-node');
  for(var i=0;i<nodes.length;i++){
    var nb=nodes[i].querySelector('.nb-collapsible');
    var toggle=nodes[i].querySelector('.nh-toggle');
    if(nb&&nb.classList.contains('nb-open')){
      nb.classList.remove('nb-open');
      if(toggle)toggle.classList.remove('open');
      var mid=nodes[i].id.match(/node-(\d+)/);
      if(mid)updateNodeSummary(mid[1]);
      var nid=nodes[i].id;
      var iv5=setInterval(function(){editor.updateConnectionNodes(nid)},30);
      setTimeout(function(){clearInterval(iv5)},320);
    }
  }
});
// Double-click to open properties panel
dfEl.addEventListener('dblclick',function(e){
  var nEl=e.target.closest('.drawflow-node');
  if(!nEl)return;
  var m=nEl.id.match(/node-(\d+)/);
  if(m){openCfg();showNodeProps(m[1])}
});

// ===== CONNECTION CLICK-SELECT + DELETE =====
var selectedConn=null;
function deselectConn(){
  if(selectedConn){selectedConn.classList.remove('conn-selected');selectedConn=null}
}
// Connection selection via click (use setTimeout to avoid interfering with Drawflow drag)
dfEl.addEventListener('click',function(e){
  // Only handle direct clicks on main-path SVG elements
  if(e.target.tagName==='path'&&e.target.classList.contains('main-path')){
    var prev=dfEl.querySelector('.main-path.conn-selected');
    if(prev&&prev!==e.target)prev.classList.remove('conn-selected');
    if(selectedConn===e.target){deselectConn();return}
    e.target.classList.add('conn-selected');
    selectedConn=e.target;
    return;
  }
  // Click on empty canvas = deselect connection
  if(selectedConn&&!e.target.closest('.drawflow-node')&&e.target.tagName!=='path'){deselectConn()}
});

// ===== SNAP TO GRID =====
var snapEnabled=true;
var GRID=24;
function toggleSnap(){
  snapEnabled=!snapEnabled;
  var el=document.getElementById('snap-toggle');
  el.classList.toggle('active',snapEnabled);
  var sb=document.getElementById('sb-snap');if(sb)sb.textContent=isHe?('\u05D4\u05E6\u05DE\u05D3: '+(snapEnabled?'\u05DE\u05D5\u05E4\u05E2\u05DC':'\u05DB\u05D1\u05D5\u05D9')):('Snap: '+(snapEnabled?'On':'Off'));
}
// Single merged nodeMoved handler: snap → dirty → undo → minimap
editor.on('nodeMoved',function(id){
  // 1. Snap to grid (must happen FIRST so undo captures snapped position)
  if(snapEnabled){
    var nd=editor.drawflow.drawflow.Home.data[id];
    if(nd){
      var sx=Math.round(nd.pos_x/GRID)*GRID;
      var sy=Math.round(nd.pos_y/GRID)*GRID;
      if(sx!==nd.pos_x||sy!==nd.pos_y){
        nd.pos_x=sx;nd.pos_y=sy;
        var el=document.getElementById('node-'+id);
        if(el){el.style.left=sx+'px';el.style.top=sy+'px';editor.updateConnectionNodes('node-'+id)}
      }
    }
  }
  // 2. Track changes + undo (AFTER snap)
  markDirty();pushUndo();
  // 3. Minimap (debounced)
  queueMM();
});

// ===== MINIMAP =====
var mmCanvas=document.getElementById('minimap-canvas');
var mmCtx=mmCanvas?mmCanvas.getContext('2d'):null;
var mmColors={trigger:'#ff6b35',message:'#6366F1',image:'#2ecc71',video:'#6c5ce7',buttons:'#00b894',menu:'#9b59b6',condition:'#f1c40f',delay:'#8e44ad',assign:'#27ae60',add_label:'#00b894',remove_label:'#00b894',set_attribute:'#e67e22',close:'#e74c3c',webhook:'#3498db',note:'#95a5a6',set_priority:'#f1c40f',set_status:'#6366F1',transfer_inbox:'#9b59b6'};
function updateMinimap(){
  if(!mmCtx)return;
  var d=editor.export().drawflow.Home.data;
  var keys=Object.keys(d);
  mmCtx.clearRect(0,0,mmCanvas.width,mmCanvas.height);
  if(!keys.length)return;
  var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
  keys.forEach(function(k){var n=d[k];if(n.pos_x<minX)minX=n.pos_x;if(n.pos_y<minY)minY=n.pos_y;if(n.pos_x+260>maxX)maxX=n.pos_x+260;if(n.pos_y+120>maxY)maxY=n.pos_y+120});
  var pad=60,rX=(maxX-minX)+pad*2,rY=(maxY-minY)+pad*2;
  var sc=Math.min(mmCanvas.width/rX,mmCanvas.height/rY);
  // Connections
  mmCtx.strokeStyle='rgba(99,102,241,.25)';mmCtx.lineWidth=1;
  keys.forEach(function(k){var n=d[k];for(var o in n.outputs){(n.outputs[o].connections||[]).forEach(function(c){var t=d[c.node];if(!t)return;mmCtx.beginPath();mmCtx.moveTo((n.pos_x+130-minX+pad)*sc,(n.pos_y+50-minY+pad)*sc);mmCtx.lineTo((t.pos_x+130-minX+pad)*sc,(t.pos_y+50-minY+pad)*sc);mmCtx.stroke()})}});
  // Nodes
  keys.forEach(function(k){var n=d[k];var x=(n.pos_x-minX+pad)*sc,y=(n.pos_y-minY+pad)*sc,w=Math.max(220*sc,6),h=Math.max(50*sc,3);mmCtx.fillStyle=mmColors[n.name]||'#6366F1';mmCtx.globalAlpha=.6;mmCtx.beginPath();mmCtx.roundRect(x,y,w,h,2);mmCtx.fill();mmCtx.globalAlpha=1});
  // Viewport
  var cRect=document.querySelector('.canvas').getBoundingClientRect();
  var vpL=(-editor.canvas_x/editor.zoom),vpT=(-editor.canvas_y/editor.zoom);
  var vpW=cRect.width/editor.zoom,vpH=cRect.height/editor.zoom;
  mmCtx.strokeStyle='rgba(99,102,241,.6)';mmCtx.lineWidth=1.5;
  mmCtx.strokeRect((vpL-minX+pad)*sc,(vpT-minY+pad)*sc,vpW*sc,vpH*sc);
}
// Update minimap on changes
var mmTimer=null;
function queueMM(){clearTimeout(mmTimer);mmTimer=setTimeout(updateMinimap,100)}
editor.on('nodeCreated',queueMM);editor.on('nodeRemoved',queueMM);
// nodeMoved minimap is handled in merged handler above
editor.on('connectionCreated',queueMM);
editor.on('connectionRemoved',queueMM);
dfEl.addEventListener('wheel',queueMM);
// Click minimap to pan
if(mmCanvas){
  mmCanvas.addEventListener('click',function(e){
    var d=editor.export().drawflow.Home.data;var keys=Object.keys(d);if(!keys.length)return;
    var minX=Infinity,minY=Infinity,maxX=-Infinity,maxY=-Infinity;
    keys.forEach(function(k){var n=d[k];if(n.pos_x<minX)minX=n.pos_x;if(n.pos_y<minY)minY=n.pos_y;if(n.pos_x+260>maxX)maxX=n.pos_x+260;if(n.pos_y+120>maxY)maxY=n.pos_y+120});
    var pad=60,rX=(maxX-minX)+pad*2,rY=(maxY-minY)+pad*2;
    var sc=Math.min(mmCanvas.width/rX,mmCanvas.height/rY);
    var rect=mmCanvas.getBoundingClientRect();
    var mx=(e.clientX-rect.left)*(mmCanvas.width/rect.width);
    var my=(e.clientY-rect.top)*(mmCanvas.height/rect.height);
    var flowX=mx/sc+minX-pad;var flowY=my/sc+minY-pad;
    var cRect=document.querySelector('.canvas').getBoundingClientRect();
    editor.canvas_x=-(flowX*editor.zoom-cRect.width/2);
    editor.canvas_y=-(flowY*editor.zoom-cRect.height/2);
    editor.precanvas.style.transform='translate('+editor.canvas_x+'px,'+editor.canvas_y+'px) scale('+editor.zoom+')';
    queueMM();
  });
}

// ===== CHAT SIMULATOR ENGINE =====
var simState={running:false,currentNodeId:null,variables:{},labels:[],visitedNodes:new Set(),visitCount:{},maxVisits:50,history:[],waitingForReply:null,waitTimer:null,flowSnapshot:null,lastUserMsg:''};
var simContact={name:'Demo User',email:'demo@example.com',phone_number:'+1-555-0100',city:'Tel Aviv',country:'Israel',id:'42',identifier:'demo-42'};

function toggleSimulator(){
  var p=document.getElementById('sim-panel');
  var isOpen=p.classList.contains('open');
  if(isOpen){p.classList.remove('open');document.body.classList.remove('sim-open')}
  else{p.classList.add('open');document.body.classList.add('sim-open');if(!simState.running)simReset()}
}

function simReset(){
  if(simState.waitTimer)clearTimeout(simState.waitTimer);
  simState={running:false,currentNodeId:null,variables:{},labels:[],visitedNodes:new Set(),visitCount:{},maxVisits:50,history:[],waitingForReply:null,waitTimer:null,flowSnapshot:null,lastUserMsg:''};
  var msgs=document.getElementById('sim-messages');while(msgs.firstChild)msgs.removeChild(msgs.firstChild);
  var ch=document.getElementById('sim-choices');while(ch.firstChild)ch.removeChild(ch.firstChild);
  var inp=document.getElementById('sim-input');inp.disabled=false;inp.placeholder=L.sim_type_msg;inp.value='';
  document.getElementById('sim-status').textContent=L.sim_start;
  simClearHighlights();
  try{simState.flowSnapshot=editor.export().drawflow.Home.data}catch(e){simState.flowSnapshot={}}
  simAddMessage('system',L.sim_start);
}

function simAddMessage(type,text,nodeId){
  var c=document.getElementById('sim-messages');
  var d=document.createElement('div');d.className='sim-msg sim-msg-'+type;
  d.textContent=text;
  if(nodeId&&type==='bot'){var t=document.createElement('div');t.className='sim-msg-node';t.textContent='Node #'+nodeId;d.appendChild(t)}
  c.appendChild(d);c.scrollTop=c.scrollHeight;
  simState.history.push({type:type,text:text,nodeId:nodeId});
}

function simShowTyping(){
  var c=document.getElementById('sim-messages');
  var d=document.createElement('div');d.className='sim-typing';d.id='sim-typing-ind';
  var s1=document.createElement('span');var s2=document.createElement('span');var s3=document.createElement('span');
  d.appendChild(s1);d.appendChild(s2);d.appendChild(s3);
  c.appendChild(d);c.scrollTop=c.scrollHeight;
}
function simHideTyping(){var e=document.getElementById('sim-typing-ind');if(e)e.remove()}

function simHighlightNode(nodeId){
  var prev=document.querySelector('.drawflow-node.sim-active');
  if(prev)prev.classList.remove('sim-active');
  var el=document.getElementById('node-'+nodeId);
  if(el){el.classList.add('sim-active');el.classList.add('sim-visited')}
  simPanToNode(nodeId);
}
function simPanToNode(nodeId){
  var nd=simState.flowSnapshot[nodeId];if(!nd)return;
  var cEl=document.querySelector('.canvas-area')||document.querySelector('.drawflow');if(!cEl)return;
  var cRect=cEl.getBoundingClientRect();
  var nx=nd.pos_x*editor.zoom+editor.canvas_x;
  var ny=nd.pos_y*editor.zoom+editor.canvas_y;
  var m=120;var rMargin=document.getElementById('sim-panel').classList.contains('open')?380:0;
  if(nx<m||nx>cRect.width-m-rMargin||ny<m||ny>cRect.height-m){
    editor.canvas_x=cRect.width/2-nd.pos_x*editor.zoom-rMargin/2;
    editor.canvas_y=cRect.height/2-nd.pos_y*editor.zoom;
    editor.precanvas.style.transform='translate('+editor.canvas_x+'px,'+editor.canvas_y+'px) scale('+editor.zoom+')';
    try{queueMM()}catch(e){}
  }
}
function simClearHighlights(){
  document.querySelectorAll('.sim-active').forEach(function(e){e.classList.remove('sim-active')});
  document.querySelectorAll('.sim-visited').forEach(function(e){e.classList.remove('sim-visited')});
}

function simInterpolate(text){
  if(!text)return '';
  return text.replace(/\{\{(\w[\w.]*)\}\}/g,function(m,key){
    if(key.indexOf('contact.')===0){var f=key.replace('contact.','');return simContact[f]||m}
    if(simState.variables[key]!==undefined)return simState.variables[key];
    return m;
  });
}

function simEvalCondition(data,msg){
  var ct=data.check_type||'contains';var cv=data.check_value||'';
  switch(ct){
    case 'contains':
      var parts=cv.split('|');
      for(var i=0;i<parts.length;i++){if(msg.toLowerCase().indexOf(parts[i].toLowerCase().trim())!==-1)return true}
      return false;
    case 'equals':return msg.toLowerCase()===cv.toLowerCase();
    case 'regex':try{return new RegExp(cv,'i').test(msg)}catch(e){return false}
    case 'label_exists':case 'has_label':return simState.labels.indexOf(cv)!==-1;
    default:return false;
  }
}

function simSend(){
  var inp=document.getElementById('sim-input');
  var text=inp.value.trim();if(!text)return;
  inp.value='';
  simAddMessage('user',text);
  simState.lastUserMsg=text;
  if(simState.waitingForReply){
    var wr=simState.waitingForReply;simState.waitingForReply=null;
    if(simState.waitTimer){clearTimeout(simState.waitTimer);simState.waitTimer=null}
    if(wr.variable)simState.variables[wr.variable]=text;
    inp.placeholder=L.sim_type_msg;
    setTimeout(function(){simFollowOutput(wr.nodeId,'output_1')},300);
    return;
  }
  var d=simState.flowSnapshot;if(!d){simAddMessage('system','No flow data');return}
  var triggers=[];
  for(var id in d){if(d[id].name==='trigger')triggers.push(d[id])}
  if(!triggers.length){simAddMessage('system',L.sim_no_trigger);return}
  var matched=null;
  for(var i=0;i<triggers.length;i++){
    var t=triggers[i];
    if(t.data.trigger_type==='keyword'&&t.data.keyword){
      var kw=t.data.keyword.split('|');
      for(var j=0;j<kw.length;j++){if(text.toLowerCase().indexOf(kw[j].toLowerCase().trim())!==-1){matched=t;break}}
      if(!matched){try{if(new RegExp(t.data.keyword,'i').test(text))matched=t}catch(e){}}
    }
    if(matched)break;
  }
  if(!matched){
    for(var i=0;i<triggers.length;i++){
      if(triggers[i].data.trigger_type==='first'&&!simState.running){matched=triggers[i];break}
      if(triggers[i].data.trigger_type==='any'){matched=triggers[i];break}
    }
  }
  if(!matched&&triggers.length===1)matched=triggers[0];
  if(!matched){simAddMessage('system',L.sim_no_trigger);return}
  simState.running=true;simState.visitCount={};simClearHighlights();
  document.getElementById('sim-status').textContent=isHe?'\u05E1\u05D9\u05DE\u05D5\u05DC\u05E6\u05D9\u05D4 \u05E4\u05E2\u05D9\u05DC\u05D4...':'Simulation running...';
  simExecuteNode(String(matched.id));
}

function simFollowOutput(nodeId,outputKey){
  var d=simState.flowSnapshot;var node=d[nodeId];if(!node)return;
  var output=node.outputs[outputKey];
  if(!output||!output.connections||!output.connections.length){
    simAddMessage('system',L.sim_flow_ended);
    document.getElementById('sim-status').textContent=L.sim_flow_ended;return;
  }
  var conn=output.connections[0];var nextId=conn.node;
  setTimeout(function(){simExecuteNode(String(nextId))},400);
}

function simExecuteNode(nodeId){
  var d=simState.flowSnapshot;var node=d[nodeId];
  if(!node){simAddMessage('system',L.sim_flow_ended);return}
  if(!simState.visitCount[nodeId])simState.visitCount[nodeId]=0;
  simState.visitCount[nodeId]++;
  if(simState.visitCount[nodeId]>simState.maxVisits){
    simAddMessage('system',L.sim_loop+' (node #'+nodeId+')');
    document.getElementById('sim-status').textContent=L.sim_loop;return;
  }
  simState.currentNodeId=nodeId;simState.visitedNodes.add(nodeId);simHighlightNode(nodeId);
  var nd=node.data||{};var inp=document.getElementById('sim-input');

  switch(node.name){
    case 'trigger':
      simAddMessage('system',L.sim_trigger_matched);
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},300);
      break;
    case 'message':
      var msg=simInterpolate(nd.message||'(empty message)');
      simAddMessage('bot',msg,nodeId);
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},600);
      break;
    case 'buttons':
      var body=simInterpolate(nd.body||'');
      if(body)simAddMessage('bot',body,nodeId);
      var choicesEl=document.getElementById('sim-choices');while(choicesEl.firstChild)choicesEl.removeChild(choicesEl.firstChild);
      var btns=[nd.btn1,nd.btn2,nd.btn3];
      btns.forEach(function(label,idx){
        if(!label)return;
        var btn=document.createElement('button');btn.className='sim-choice-btn';btn.textContent=label;
        btn.onclick=function(){while(choicesEl.firstChild)choicesEl.removeChild(choicesEl.firstChild);simAddMessage('user',label);simState.lastUserMsg=label;inp.disabled=false;simFollowOutput(nodeId,'output_'+(idx+1))};
        choicesEl.appendChild(btn);
      });
      inp.disabled=true;
      break;
    case 'menu':
      var title=simInterpolate(nd.body||nd.title||'');
      if(title)simAddMessage('bot',title,nodeId);
      var choicesEl=document.getElementById('sim-choices');while(choicesEl.firstChild)choicesEl.removeChild(choicesEl.firstChild);
      for(var oi=1;oi<=6;oi++){
        var optLabel=nd['opt'+oi];if(!optLabel)continue;
        (function(idx,lbl){
          var btn=document.createElement('button');btn.className='sim-choice-btn';btn.textContent=lbl;
          btn.onclick=function(){while(choicesEl.firstChild)choicesEl.removeChild(choicesEl.firstChild);simAddMessage('user',lbl);simState.lastUserMsg=lbl;inp.disabled=false;simFollowOutput(nodeId,'output_'+idx)};
          choicesEl.appendChild(btn);
        })(oi,optLabel);
      }
      inp.disabled=true;
      break;
    case 'condition':
      var result=simEvalCondition(nd,simState.lastUserMsg);
      var arrow=result?'\u2714 Yes':'\u2718 No';
      simAddMessage('system',L.sim_condition+(nd.check_type||'contains')+' "'+String(nd.check_value||'')+'" \u2192 '+arrow);
      setTimeout(function(){simFollowOutput(nodeId,result?'output_1':'output_2')},500);
      break;
    case 'delay':
      var secs=Math.min(parseInt(nd.seconds)||3,3);
      if(nd.typing==='true'||nd.typing===true)simShowTyping();
      else simAddMessage('system',(isHe?'\u05D4\u05DE\u05EA\u05E0\u05D4 ':'Waiting ')+secs+'s...');
      setTimeout(function(){simHideTyping();simFollowOutput(nodeId,'output_1')},secs*1000);
      break;
    case 'wait_reply':
      simAddMessage('system',L.sim_waiting);
      var toSec=Math.min(parseInt(nd.timeout_seconds||nd.timeout)||300,15);
      simState.waitingForReply={nodeId:nodeId,variable:nd.save_as||nd.variable||'',timeoutSec:toSec};
      inp.disabled=false;inp.placeholder=L.sim_type_reply;inp.focus();
      simState.waitTimer=setTimeout(function(){
        if(!simState.waitingForReply)return;simState.waitingForReply=null;
        if(nd.timeout_message)simAddMessage('bot',simInterpolate(nd.timeout_message));
        simAddMessage('system',L.sim_timeout);inp.placeholder=L.sim_type_msg;
        simFollowOutput(nodeId,'output_2');
      },toSec*1000);
      break;
    case 'close':
      simAddMessage('system',L.sim_closed);inp.disabled=true;
      document.getElementById('sim-status').textContent=L.sim_closed;
      break;
    case 'assign':
      var who='';
      if(nd.agent_id){var ag=agents.find(function(a){return String(a.id)===String(nd.agent_id)});who=ag?ag.name:'Agent #'+nd.agent_id}
      if(nd.team_id){var tm=teams.find(function(t){return String(t.id)===String(nd.team_id)});who=tm?tm.name:'Team #'+nd.team_id}
      simAddMessage('system',L.sim_assigned+(who||'?'));
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},400);
      break;
    case 'add_label':
      var lbl=nd.label||nd.label_id||'';simState.labels.push(lbl);
      simAddMessage('system',L.sim_label_add+lbl);
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},300);
      break;
    case 'remove_label':
      var lbl=nd.label||nd.label_id||'';simState.labels=simState.labels.filter(function(l){return l!==lbl});
      simAddMessage('system',L.sim_label_rm+lbl);
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},300);
      break;
    case 'image':
      simAddMessage('bot','\uD83D\uDDBC\uFE0F Image: '+(nd.url||'(no url)'),nodeId);
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},400);
      break;
    case 'video':
      simAddMessage('bot','\uD83C\uDFAC Video: '+(nd.url||'(no url)'),nodeId);
      setTimeout(function(){simFollowOutput(nodeId,'output_1')},400);
      break;
    default:
      simAddMessage('system',L.sim_action+node.name);
      if(node.outputs&&node.outputs.output_1&&node.outputs.output_1.connections&&node.outputs.output_1.connections.length){
        setTimeout(function(){simFollowOutput(nodeId,'output_1')},300);
      }
      break;
  }
}

// Welcome Bot template for new bots
function loadWelcomeBotTemplate(){
  var tpl={drawflow:{Home:{data:{
    "1":{id:1,name:"trigger",data:{trigger_type:"any",keyword:""},class:"trigger",html:"",typenode:false,inputs:{},outputs:{output_1:{connections:[{node:"2",output:"input_1"}]}},pos_x:80,pos_y:150},
    "2":{id:2,name:"message",data:{message:"Hi {{contact.name}}! \uD83D\uDC4B Welcome to our support. How can we help you today?"},class:"message",html:"",typenode:false,inputs:{input_1:{connections:[{node:"1",input:"output_1"}]}},outputs:{output_1:{connections:[{node:"3",output:"input_1"}]}},pos_x:400,pos_y:120},
    "3":{id:3,name:"menu",data:{body:"Please choose an option:",opt1:"\uD83D\uDCB0 Sales & Pricing",opt2:"\uD83D\uDD27 Technical Support",opt3:"\uD83D\uDCCB Billing Questions",opt4:"",opt5:"",opt6:""},class:"menu",html:"",typenode:false,inputs:{input_1:{connections:[{node:"2",input:"output_1"}]}},outputs:{output_1:{connections:[{node:"5",output:"input_1"}]},output_2:{connections:[{node:"6",output:"input_1"}]},output_3:{connections:[{node:"7",output:"input_1"}]},output_4:{connections:[]},output_5:{connections:[]},output_6:{connections:[]}},pos_x:740,pos_y:80},
    "5":{id:5,name:"add_label",data:{label:"Sales Lead"},class:"add_label",html:"",typenode:false,inputs:{input_1:{connections:[{node:"3",input:"output_1"}]}},outputs:{output_1:{connections:[{node:"8",output:"input_1"}]}},pos_x:1100,pos_y:30},
    "6":{id:6,name:"message",data:{message:"I'll connect you with our technical team right away. Please describe your issue briefly."},class:"message",html:"",typenode:false,inputs:{input_1:{connections:[{node:"3",input:"output_2"}]}},outputs:{output_1:{connections:[{node:"9",output:"input_1"}]}},pos_x:1100,pos_y:190},
    "7":{id:7,name:"message",data:{message:"For billing questions, please have your account number ready. Connecting you now..."},class:"message",html:"",typenode:false,inputs:{input_1:{connections:[{node:"3",input:"output_3"}]}},outputs:{output_1:{connections:[{node:"10",output:"input_1"}]}},pos_x:1100,pos_y:370},
    "8":{id:8,name:"assign",data:{agent_id:"",team_id:"1"},class:"assign",html:"",typenode:false,inputs:{input_1:{connections:[{node:"5",input:"output_1"}]}},outputs:{output_1:{connections:[]}},pos_x:1440,pos_y:30},
    "9":{id:9,name:"assign",data:{agent_id:"",team_id:"2"},class:"assign",html:"",typenode:false,inputs:{input_1:{connections:[{node:"6",input:"output_1"}]}},outputs:{output_1:{connections:[]}},pos_x:1440,pos_y:190},
    "10":{id:10,name:"assign",data:{agent_id:"1",team_id:""},class:"assign",html:"",typenode:false,inputs:{input_1:{connections:[{node:"7",input:"output_1"}]}},outputs:{output_1:{connections:[]}},pos_x:1440,pos_y:370}
  }}}};
  document.getElementById('bname').value='Welcome Bot';
  try{document.getElementById('bdesc').value='Greets new visitors and routes them to the right team'}catch(e){}
  editor.import(tpl);
  setTimeout(function(){
    try{popSelects();updStats();addAllNodeActions();upgradeLoadedNodes();updateAllSummaries();autoAlign()}catch(e){}
  },200);
}

// ===== INIT =====
loadMeta().then(function(){
  if(BOT_ID)return loadBot(BOT_ID);
  return loadWelcomeBotTemplate();
}).then(function(){
  var cl=document.getElementById('canvas-loading');if(cl)cl.classList.add('done');
  updUndoState();
  try{if(localStorage.getItem('bb-cfg-open'))openCfg()}catch(ex){}
});
setTimeout(queueMM,800);

// ===== i18n: translate static HTML elements for Hebrew =====
(function(){
  if(!isHe) return;
  // Set RTL on document
  document.documentElement.setAttribute('dir','rtl');
  document.documentElement.setAttribute('lang','he');

  // --- Page title ---
  document.title='\u05E2\u05D5\u05E8\u05DA \u05D1\u05D5\u05D8 | Chatwoot';

  // --- Top hint bar ---
  var hint=document.querySelector('.hint');
  if(hint) hint.textContent='\u05D2\u05E8\u05D5\u05E8 \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD \u05DC\u05E7\u05E0\u05D1\u05E1 \u2022 \u05DC\u05D7\u05D9\u05E6\u05D4 \u05DB\u05E4\u05D5\u05DC\u05D4 = \u05E2\u05E8\u05D9\u05DB\u05D4 \u2022 \u05D2\u05DC\u05DC = \u05D6\u05D5\u05DD \u2022 \u05D7\u05D1\u05E8 \u05E4\u05D5\u05E8\u05D8\u05D9\u05DD';

  // --- Canvas empty hint ---
  var ceH3=document.querySelector('#canvas-empty h3');
  if(ceH3) ceH3.textContent='\u05D1\u05E0\u05D4 \u05D1\u05D5\u05D8 \u05D1-3 \u05E6\u05E2\u05D3\u05D9\u05DD';
  var steps=document.querySelectorAll('#canvas-empty .empty-steps div');
  if(steps.length>=3){
    steps[0].innerHTML='\u2460 \u05D4\u05EA\u05D7\u05DC \u05E2\u05DD <strong>\u05D8\u05E8\u05D9\u05D2\u05E8</strong> (\u05D4\u05D5\u05D3\u05E2\u05D4 \u05E0\u05DB\u05E0\u05E1\u05EA)';
    steps[1].innerHTML='\u2461 \u05D4\u05D5\u05E1\u05E3 <strong>\u05E4\u05E2\u05D5\u05DC\u05D5\u05EA</strong> (\u05D4\u05D5\u05D3\u05E2\u05D4, \u05DB\u05E4\u05EA\u05D5\u05E8\u05D9\u05DD, \u05EA\u05E4\u05E8\u05D9\u05D8...)';
    steps[2].innerHTML='\u2462 \u05D7\u05D1\u05E8 \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD \u05DC\u05D9\u05E6\u05D9\u05E8\u05EA \u05D6\u05E8\u05D9\u05DE\u05D4';
  }
  // Keyboard shortcuts in empty canvas
  var ceP=document.querySelector('#canvas-empty p');
  if(ceP) ceP.innerHTML='<kbd>Ctrl</kbd>+<kbd>Z</kbd> \u05D1\u05D8\u05DC \u2022 <kbd>Ctrl</kbd>+<kbd>S</kbd> \u05E9\u05DE\u05D5\u05E8 \u2022 <kbd>Del</kbd> \u05DE\u05D7\u05E7';

  // --- Loading text ---
  var ldSpan=document.querySelector('#canvas-loading span');
  if(ldSpan) ldSpan.textContent='\u05D8\u05D5\u05E2\u05DF...';

  // --- Bot name placeholder ---
  var bname=document.getElementById('bname');
  if(bname) bname.placeholder='\u05DC\u05D7\u05E5 \u05DC\u05E2\u05E8\u05D9\u05DB\u05EA \u05E9\u05DD \u05D4\u05D1\u05D5\u05D8...';

  // --- Save button ---
  var savebtn=document.getElementById('savebtn');
  if(savebtn) savebtn.innerHTML='<i class="ti ti-device-floppy"></i> \u05E9\u05DE\u05D5\u05E8';

  // --- Snap button ---
  var snapLabel=document.getElementById('snap-label');
  if(snapLabel) snapLabel.textContent='\u05D4\u05E6\u05DE\u05D3';

  // --- Status bar ---
  var sbNodes=document.getElementById('sb-nodes');
  if(sbNodes) sbNodes.textContent='0 \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD';
  var sbConns=document.getElementById('sb-conns');
  if(sbConns) sbConns.textContent='0 \u05D7\u05D9\u05D1\u05D5\u05E8\u05D9\u05DD';
  var sbSnap=document.getElementById('sb-snap');
  if(sbSnap) sbSnap.textContent='\u05D4\u05E6\u05DE\u05D3: \u05DE\u05D5\u05E4\u05E2\u05DC';

  // --- Search nodes placeholder ---
  var nsearch=document.getElementById('node-search');
  if(nsearch) nsearch.placeholder='\u05D7\u05E4\u05E9 \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD...';

  // --- No nodes found ---
  var noRes=document.getElementById('nodes-no-results');
  if(noRes){var t=noRes.childNodes;for(var i=0;i<t.length;i++){if(t[i].nodeType===3&&t[i].textContent.trim()==='No nodes found'){t[i].textContent='\u05DC\u05D0 \u05E0\u05DE\u05E6\u05D0\u05D5 \u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD'}}}

  // --- Sidebar section headers ---
  var secTs=document.querySelectorAll('.sec-t .dn-label');
  var secMap={'Triggers':'\u05D8\u05E8\u05D9\u05D2\u05E8\u05D9\u05DD','Messages':'\u05D4\u05D5\u05D3\u05E2\u05D5\u05EA','Logic':'\u05DC\u05D5\u05D2\u05D9\u05E7\u05D4','Actions':'\u05E4\u05E2\u05D5\u05DC\u05D5\u05EA','Integrations':'\u05D0\u05D9\u05E0\u05D8\u05D2\u05E8\u05E6\u05D9\u05D5\u05EA'};
  for(var i=0;i<secTs.length;i++){var txt=secTs[i].textContent.trim();if(secMap[txt])secTs[i].textContent=secMap[txt]}

  // --- Sidebar node palette labels + titles ---
  var dnMap={
    'Incoming Message':L.incoming_msg, 'Send Message':L.send_msg, 'Send Image':L.send_img,
    'Send Video':L.send_vid, 'Buttons':L.buttons_title, 'Menu':L.menu_title,
    'Condition':L.condition_title, 'Delay':L.delay_title, 'Internal Note':L.note_title,
    'Wait for Reply':L.wait_reply_title, 'A/B Split':'A/B Split',
    'Go to Step':L.goto_title, 'Assign to Agent':L.assign_title,
    'Add Label':L.add_label_title, 'Remove Label':L.remove_label_title,
    'Set Attribute':L.set_attr_title, 'Set Priority':L.priority_title,
    'Set Status':L.status_title, 'Transfer Inbox':L.transfer_title,
    'Close Conversation':L.close_title, 'Webhook':'Webhook', 'API Action':'API Action'
  };
  var dns=document.querySelectorAll('.side-nodes .dn');
  for(var i=0;i<dns.length;i++){
    var lbl=dns[i].querySelector('.dn-label');
    if(lbl){var t=lbl.textContent.trim();if(dnMap[t])lbl.textContent=dnMap[t]}
    var tt=dns[i].getAttribute('title');
    if(tt&&dnMap[tt])dns[i].setAttribute('title',dnMap[tt]);
  }

  // --- Toolbar tooltips ---
  var ttMap={
    'Undo (Ctrl+Z)':'\u05D1\u05D8\u05DC (Ctrl+Z)',
    'Redo (Ctrl+Shift+Z)':'\u05D1\u05D8\u05DC \u05D1\u05D9\u05D8\u05D5\u05DC (Ctrl+Shift+Z)',
    'Bot Settings':'\u05D4\u05D2\u05D3\u05E8\u05D5\u05EA \u05D1\u05D5\u05D8',
    'Auto-align':'\u05E1\u05D9\u05D3\u05D5\u05E8 \u05D0\u05D5\u05D8\u05D5\u05DE\u05D8\u05D9',
    'Validate Flow':'\u05D1\u05D3\u05D9\u05E7\u05EA \u05D6\u05E8\u05D9\u05DE\u05D4',
    'Export Flow (JSON)':'\u05D9\u05D9\u05E6\u05D5\u05D0 \u05D6\u05E8\u05D9\u05DE\u05D4 (JSON)',
    'Import Flow (JSON)':'\u05D9\u05D9\u05D1\u05D5\u05D0 \u05D6\u05E8\u05D9\u05DE\u05D4 (JSON)',
    'Expand/Collapse palette':'\u05D4\u05E8\u05D7\u05D1/\u05E6\u05DE\u05E6\u05DD \u05E4\u05DC\u05D8\u05D4',
    'Fit to screen':'\u05D4\u05EA\u05D0\u05DE\u05D4 \u05DC\u05DE\u05E1\u05DA',
    'Reset':'\u05D0\u05D9\u05E4\u05D5\u05E1',
    'Snap to grid':'\u05D4\u05E6\u05DE\u05D3 \u05DC\u05E8\u05E9\u05EA',
    'Back to list':'\u05D7\u05D6\u05E8\u05D4 \u05DC\u05E8\u05E9\u05D9\u05DE\u05D4',
    'Duplicate':'\u05E9\u05DB\u05E4\u05D5\u05DC',
    'Delete':'\u05DE\u05D7\u05E7'
  };
  var titled=document.querySelectorAll('[title]');
  for(var i=0;i<titled.length;i++){var t=titled[i].getAttribute('title');if(ttMap[t])titled[i].setAttribute('title',ttMap[t])}

  // --- Nav tooltips ---
  var navMap={'Bot Builder':'\u05D1\u05D5\u05E0\u05D4 \u05D1\u05D5\u05D8\u05D9\u05DD','Campaign Report':'\u05D3\u05D5\u05D7 \u05E7\u05DE\u05E4\u05D9\u05D9\u05E0\u05D9\u05DD','Chatwoot':'Chatwoot'};
  var navLinks=document.querySelectorAll('.app-nav a');
  for(var i=0;i<navLinks.length;i++){var t=navLinks[i].getAttribute('title');if(navMap[t])navLinks[i].setAttribute('title',navMap[t])}

  // --- Context menu ---
  var ctxItems=document.querySelectorAll('.ctx-item');
  var ctxMap={'Duplicate':'\u05E9\u05DB\u05E4\u05D5\u05DC','Copy':'\u05D4\u05E2\u05EA\u05E7','Paste':'\u05D4\u05D3\u05D1\u05E7','Delete':'\u05DE\u05D7\u05E7'};
  for(var i=0;i<ctxItems.length;i++){
    var nodes=ctxItems[i].childNodes;
    for(var j=0;j<nodes.length;j++){
      if(nodes[j].nodeType===3){var txt=nodes[j].textContent.trim();if(ctxMap[txt])nodes[j].textContent=' '+ctxMap[txt]}
    }
  }

  // --- Settings sidebar ---
  var sideCfg=document.getElementById('side-cfg');
  if(sideCfg){
    sideCfg.setAttribute('aria-label','\u05D4\u05D2\u05D3\u05E8\u05D5\u05EA \u05D1\u05D5\u05D8');
    // Close button
    var closeBtn=sideCfg.querySelector('.side-cfg-close');
    if(closeBtn) closeBtn.innerHTML='<i class="ti ti-chevron-right" style="font-size:14px"></i> \u05E1\u05D2\u05D5\u05E8 <kbd>Esc</kbd>';
    // Bot Settings heading
    var cfgH3s=sideCfg.querySelectorAll('h3');
    for(var i=0;i<cfgH3s.length;i++){
      var t=cfgH3s[i].textContent.trim();
      if(t.indexOf('Bot Settings')!==-1) cfgH3s[i].innerHTML='<i class="ti ti-settings" style="font-size:16px;vertical-align:middle"></i> \u05D4\u05D2\u05D3\u05E8\u05D5\u05EA \u05D1\u05D5\u05D8';
      if(t.indexOf('Info')!==-1) cfgH3s[i].innerHTML='<i class="ti ti-chart-bar" style="font-size:16px;vertical-align:middle"></i> \u05DE\u05D9\u05D3\u05E2';
      if(t.indexOf('Tips')!==-1) cfgH3s[i].innerHTML='<i class="ti ti-bulb" style="font-size:16px;vertical-align:middle"></i> \u05D8\u05D9\u05E4\u05D9\u05DD';
      if(t.indexOf('Issues')!==-1) cfgH3s[i].innerHTML='<i class="ti ti-alert-triangle" style="font-size:16px;vertical-align:middle"></i> \u05D1\u05E2\u05D9\u05D5\u05EA';
    }
    // Labels in settings
    var labels=sideCfg.querySelectorAll('label');
    var labMap={'Description':'\u05EA\u05D9\u05D0\u05D5\u05E8','Inboxes':'\u05EA\u05D9\u05D1\u05D5\u05EA \u05D3\u05D5\u05D0\u05E8'};
    for(var i=0;i<labels.length;i++){var t=labels[i].textContent.trim();if(labMap[t])labels[i].textContent=labMap[t]}
    // Description placeholder
    var bdesc=document.getElementById('bdesc');
    if(bdesc) bdesc.placeholder='\u05EA\u05D9\u05D0\u05D5\u05E8 \u05E7\u05E6\u05E8...';
    // Info rows
    var srs=sideCfg.querySelectorAll('.sr .lab');
    var srMap={'Status':'\u05E1\u05D8\u05D8\u05D5\u05E1','Nodes':'\u05D0\u05DC\u05DE\u05E0\u05D8\u05D9\u05DD','Connections':'\u05D7\u05D9\u05D1\u05D5\u05E8\u05D9\u05DD','Last updated':'\u05E2\u05D3\u05DB\u05D5\u05DF \u05D0\u05D7\u05E8\u05D5\u05DF'};
    for(var i=0;i<srs.length;i++){var t=srs[i].textContent.trim();if(srMap[t])srs[i].textContent=srMap[t]}
    // Status value
    var stS=document.getElementById('st-s');
    if(stS){var sv=stS.textContent.trim();if(sv==='New')stS.textContent='\u05D7\u05D3\u05E9'}
    // Tips content
    var tipsDiv=document.querySelector('#tips-panel div[style]');
    if(tipsDiv) tipsDiv.innerHTML='<i class="ti ti-drag-drop" style="font-size:13px"></i> \u05D2\u05E8\u05D5\u05E8 \u05D0\u05DC\u05DE\u05E0\u05D8 \u05DC\u05E7\u05E0\u05D1\u05E1<br><i class="ti ti-mouse" style="font-size:13px"></i> \u05DC\u05D7\u05D9\u05E6\u05D4 \u05DB\u05E4\u05D5\u05DC\u05D4 = \u05E2\u05E8\u05D9\u05DB\u05D4<br><i class="ti ti-device-floppy" style="font-size:13px"></i> Ctrl+S = \u05E9\u05DE\u05D9\u05E8\u05D4<br><i class="ti ti-backspace" style="font-size:13px"></i> Delete = \u05DE\u05D7\u05D9\u05E7\u05EA \u05D0\u05DC\u05DE\u05E0\u05D8<br><i class="ti ti-arrow-back-up" style="font-size:13px"></i> Ctrl+Z = \u05D1\u05D9\u05D8\u05D5\u05DC<br><i class="ti ti-menu-2" style="font-size:13px"></i> \u05DC\u05D7\u05D9\u05E6\u05D4 \u05D9\u05DE\u05E0\u05D9\u05EA = \u05EA\u05E4\u05E8\u05D9\u05D8';
  }
  // --- Simulator UI i18n ---
  var simTitle=document.getElementById('sim-title-text');
  if(simTitle)simTitle.textContent=L.sim_title;
  var simStatus=document.getElementById('sim-status');
  if(simStatus)simStatus.textContent=L.sim_start;
  var simInput=document.getElementById('sim-input');
  if(simInput)simInput.placeholder=L.sim_type_msg;
  var testLabel=document.getElementById('test-bot-label');
  if(testLabel)testLabel.textContent=L.sim_test_bot;
  // Demo banner i18n
  var bannerSpan=document.querySelector('.demo-banner span');
  if(bannerSpan)bannerSpan.textContent=L.sim_demo_banner;
})();
