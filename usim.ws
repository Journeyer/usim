#!/usr/bin/env wsapi.cgi

local orbit = require "orbit"
local cosmo = require "cosmo"
local luasql = require "luasql.sqlite3"

local usim = orbit.new()

usim.mapper.logging = true
usim.mapper.conn = luasql.sqlite3():connect(usim.real_path .. "/usim.db")

usim.list = usim:model("usim_list")

local function item_list()
  return usim.list:find_all{ order = "created_at desc" }
end

-- index --
local function index(web)
  local list = web:page_inline(usim.items, { items = item_list() })
  return web:page_inline(usim.index, { items = list })
end

usim:dispatch_get(index, "/")

-- add --
local function add(web)
  local item = usim.list:new()
  item.msisdn = web.input.msisdn or ""
  item.imei = web.input.imei or ""
  item.serial = web.input.serial or ""
  item.operator = web.input.operator or ""
  item.user_name = web.input.name or ""
  item.user_team = web.input.team or ""
  item:save()
  return web:page_inline(usim.items, { items = item_list() })
end

usim:dispatch_post(add, "/add")

-- update --
local function update(web, id) 
  local item = usim.list:find(tonumber(id))
  item.msisdn = web.input.msisdn or ""
  item.imei = web.input.imei or ""
  item.serial = web.input.serial or ""
  item.operator = web.input.operator or ""
  item.user_name = web.input.name or ""
  item.user_team = web.input.team or ""
  item:save()
  return web:page_inline(usim.items, { items = item_list() })
end

usim:dispatch_post(update, "/update/(%d+)")

-- remove --
local function remove(web, id) 
  local item = usim.list:find(tonumber(id))
  item:delete()
  return web:page_inline(usim.items, { items = item_list() })
end

usim:dispatch_post(remove, "/remove/(%d+)")

-- toggle --
local function toggle(web, id) 
  local item = usim.list:find(tonumber(id))
  item.done = not item.done
  item:save()
  return "toggle"
end

usim:dispatch_post(toggle, "/toggle/(%d+)")

usim:dispatch_static(".+%.js")

usim.index = [===[
<html>
<head>
<title>USIMs</title>
<script type="text/javascript" src="$static_link{'/jquery-1.2.3.min.js'}"></script>
<script>
function set_callbacks() {
  $$(".item_done").click(function () {
    $$.post("$link{ '/toggle/' }" + $$(this).parent().parent().parent().attr("item_id"), {});
  });
  $$(".item_remove").click(function () {
    console.log($$(this).parent().parent().attr("item_id"));
    $$("#items").load("$link{ '/remove/' }" + $$(this).parent().parent().attr("item_id"), {},
                      function () { set_callbacks();
                      });
  });
  $$(".item_update").click(function () {
    $$("#items").load("$link{ '/update/' }" + $$(this).parent().parent().attr("item_id"), {
                         msisdn:   $$(this).parent().siblings().find(".input_text_msisdn").val(),
                         imei:     $$(this).parent().siblings().find(".input_text_imei").val(),
                         serial:   $$(this).parent().siblings().find(".input_text_serial").val(),
                         operator: $$(this).parent().siblings().find(".input_text_operator").val(),
                         name:     $$(this).parent().siblings().find(".input_text_name").val(),
                         team:     $$(this).parent().siblings().find(".input_text_team").val(),
                      },
                      function () { set_callbacks();
                      });
  });
}
$$(document).ready(function () {
  $$("#form_post").submit(function () {
    $$("#input_submit_add").attr("disabled", true);
    $$("#items").load("$link{ '/add' }", {
                         msisdn: $$("#input_text_msisdn").val(),
                         imei: $$("#input_text_imei").val(),
                         serial: $$("#input_text_serial").val(),
                         operator: $$("#input_text_operator").val(),
                         name: $$("#input_text_name").val(),
                         team: $$("#input_text_team").val(),
                       },
                       function () {
                         $$("#input_text_msisdn").val("");
                         $$("#input_text_imei").val("");
                         $$("#input_text_serial").val("");
                         $$("#input_text_operator").val("");
                         $$("#input_text_name").val("");
                         $$("#input_text_team").val("");
                         set_callbacks();
                         $$("#input_submit_add").attr("disabled",false);
                         }
                       );
    return false;
  });
  set_callbacks();
});
</script>
$include{ "style.css" }
</head>
<body>
<form id = "form_post" method = "POST" action = "$link{'/add'}">
<div class="Table" id="items">
$items
</div>
</form>
</body>
</html>
]===]

usim.items = [===[
  $if{$items|1}[==[
  <div class="Title">
    <p>USIM Status</p>
  </div>
  <div class="Heading">
    <div class="Cell">
      <p>returned</p>
    </div>
    <div class="Cell">
      <p>msisdn</p>
    </div>
    <div class="Cell">
      <p>imei</p>
    </div>
    <div class="Cell">
      <p>serial</p>
    </div>
    <div class="Cell">
      <p>operator</p>
    </div>
    <div class="Cell">
      <p>user_name</p>
    </div>
    <div class="Cell">
      <p>user_team</p>
    </div>
  </div>
$items[[
  <div class="Row" item_id="$id">
    <div class="Cell">
      <p><input class="item_done" type="checkbox" $if{$done}[=[checked]=]/></p>
    </div>
    <div class="Cell">
      <p><input type=text class = "input_text_msisdn" value="$msisdn"/></p>
    </div>
    <div class="Cell">
      <p><input type=text class = "input_text_imei" value="$imei"/></p>
    </div>
    <div class="Cell">
      <p><input type=text class = "input_text_serial" value="$serial"/></p>
    </div>
    <div class="Cell">
      <p><input type=text class = "input_text_operator" value="$operator"/></p>
    </div>
    <div class="Cell">
      <p><input type=text class = "input_text_name" value="$user_name"/></p>
    </div>
    <div class="Cell">
      <p><input type=text class = "input_text_team" value="$user_team"/></p>
    </div>
    <div class="Cell">
      <button type="button" class = "item_update">Update</button>
      <button type="button" class = "item_remove">Remove</button>
    </div>
  </div>
]]
]==],[==[Nothing to do!]==]
<div class="Row">
  <div class="Cell">
    <p></p>
  </div>
  <div class="Cell">
    <p><input id = "input_text_msisdn" type = "text" name = "msisdn" /></p>
  </div>
  <div class="Cell">
    <p><input id = "input_text_imei" type = "text" name = "imei" /></p>
  </div>
  <div class="Cell">
    <p><input id = "input_text_serial" type = "text" name = "serial" /></p>
  </div>
  <div class="Cell">
    <p><input id = "input_text_operator" type = "text" name = "operator" /></p>
  </div>
  <div class="Cell">
    <p><input id = "input_text_name" type = "text" name = "name" /></p>
  </div>
  <div class="Cell">
    <p><input id = "input_text_team" type = "text" name = "team" /></p>
  </div>
  <div class="Cell">
    <p><input id = "input_submit_add" type = "submit" value = "Add" /></p>
  </div>
</div>
]===]

return usim
