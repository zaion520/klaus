-- Copyright (C) 2017 yushi By Alx
-- Licensed to the public under the GNU General Public License v3.


local m, s,sec, o,kcp_enable
local shadowsocksr = "shadowsocksr"
local uci = luci.model.uci.cursor()
local ipkg = require("luci.model.ipkg")

local sys = require "luci.sys"

local gfwmode=0

local pdnsd_flag=0

local Pcap_Dns = 0



if nixio.fs.access("/etc/config/pcap-dnsproxy") then
	Pcap_Dns=1
end

if nixio.fs.access("/etc/dnsmasq.ssr/gfw_list.conf") then
	gfwmode=1
end

if nixio.fs.access("/etc/pdnsd.conf") then
	pdnsd_flag=1
end

m = Map(shadowsocksr)

local server_table = {}

local encrypt_methods = {
"none",
"rc4-md5",
"rc4-md5-6",
"aes-128-cfb",
"aes-192-cfb",
"aes-256-cfb",
"aes-128-ctr",
"aes-192-ctr",
"aes-256-ctr",
"bf-cfb",
"camellia-128-cfb",
"camellia-192-cfb",
"camellia-256-cfb",
"cast5-cfb",
"des-cfb",
"idea-cfb",
"rc2-cfb",
"seed-cfb",
"salsa20",
"chacha20",
"chacha20-ietf",

}

local protocol = {
"origin",
"verify_simple",
"auth_sha1_v4",
"auth_aes128_sha1",
"auth_aes128_md5",
"auth_chain_a",
"auth_chain_b",
"auth_chain_c",
"auth_chain_d",
"auth_chain_e",
}

local obfs = {
"plain",
"http_simple",
"http_post",
"tls1.2_ticket_auth",
}



uci:foreach(shadowsocksr, "servers", function (s)
	if s.alias then
		server_table[s[".name"]] = s.alias
	elseif s.server and s.server_port then
		server_table[s[".name"]] = "%s:%s" %{s.server, s.server_port}
	end
end)



-- [[ Servers Setting ]]--
sec = m:section(TypedSection, "servers", translate("Servers Setting"))
sec.anonymous = true
sec.addremove = true
sec.sortable = true
sec.template = "cbi/tblsection"
sec.extedit = luci.dispatcher.build_url("admin/services/shadowsocksr/clientlist/%s")
function sec.create(...)
	local sid = TypedSection.create(...)
	if sid then
		luci.http.redirect(sec.extedit % sid)
		return
	end
end

o = sec:option(DummyValue, "alias", translate("Alias"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or translate("None")
end


o = sec:option(DummyValue, "server", translate("Server Address"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end

o = sec:option(DummyValue, "server_port", translate("Server Port"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end

o = sec:option(DummyValue, "encrypt_method", translate("Encrypt Method"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end

o = sec:option(DummyValue, "protocol", translate("Protocol"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end


o = sec:option(DummyValue, "obfs", translate("Obfs"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "?"
end



o = sec:option(DummyValue, "switch_enable", translate("Auto Switch"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "0"
end







return m