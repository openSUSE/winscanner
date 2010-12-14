$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'pp'
require 'win_scanner/client'

client = WinScanner::Client.new(:host => "10.10.101.139")

#client.each_instance("Win32_OperatingSystem") do |os|
#  puts os.Name
#
#end

client.each_instance("Win32_UserDesktop") do |os|
  puts os.Element
  puts os.Setting
  puts os.Setting.Wallpaper
end



