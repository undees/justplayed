require 'rubygems'
require 'sinatra'

# <!-- http://mobile.yes.com/song.jsp?city=24&station=KNRK_94.7&hm=1000 -->

get '/:time' do |time|
  <<HERE
<html>
<body>
<table width="100%" align="center" cellspacing="0">
  <tr>
    <td align="left" valign="top"><img src="image.gif" alt="YES" border="0" align="top"/></td>
  </tr>
  <tr>
    <td><div align="center"><b>Now Playing (KNRK 94.7)</b></div></td>
  </tr>
  <tr>
    <td>Been Caught Stealing<br/>by Jane's Addiction<br/>10:00 AM<br/>Ritual de lo Habitual</td>
  </tr>
</table>
</body>
</html>
HERE
end
