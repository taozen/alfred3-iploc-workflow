# BSD 2-Clause License
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

def valid_ip?(str)
  ip_ary = str.split('.')
  ip_ary.size == 4 && ip_ary.all?{|x| x.match(/^\d{1,3}$/) && (0..255).include?(x.to_i)}
end

query = ARGV[0].strip
hint = ""

if query == "me"
  output = %x{curl -s http://myip.ipip.net 2>&1}.strip

  if output =~ /\D+(\d+\.\d+\.\d+\.\d+).*/
    query = $1

    # Don't forget the trailing comma.
    hint = %Q|{"subtitle": "My IP","title": "#{query}","icon": {"path": "network.png"}},|
  else
    puts %Q|{"items": [{"title": "无法获取IP地址: #{output}","icon": {"path": "help.png"}}]}|
    exit
  end
end

if !valid_ip?(query)
  puts %q|{"items": [{"title": "IP格式错误","icon": {"path": "help.png"}}]}|
  exit
end

ans = %x{curl -s http://freeapi.ipip.net/#{query}}
ary = ans.tr("\"[] ", '').split(',', -1)
ary.map!{|x| x.empty? ? "N/A" : x}

puts <<-EOF
{
  "items": [
    #{hint}
	{"subtitle": "Country","title": "#{ary[0]}","icon": {"path": "network.png"}},
	{"subtitle": "Province","title": "#{ary[1]}","icon": {"path": "network.png"}},
	{"subtitle": "City","title": "#{ary[2]}","icon": {"path": "network.png"}},
	{"subtitle": "ISP","title": "#{ary[4]}","icon": {"path": "network.png"}}
  ]
}
EOF

