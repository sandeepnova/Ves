<html>
<head>
  <title>Allied Health Index Page | Version:1.1</title>
</head>

<body class="body0">
  <cfset tab_Width = "100%">
  <cfset tab_align = "left">
  <cfset tab_type = "link">
  <cfset tab_linkall = "yes">
  <cfset tab_bgcolor = "##fffff0">
  <cfset v_function_id = 11165>
  <cfset v_default_tab = 20865>
  <cfinclude template="/#application.maprootdir#/commonfiles/build_tab.cfm">
  <cfinclude template="/#application.maprootdir#/commonfiles/cf_tab.cfm">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td>
          <iframe frameborder="0" src="ah_main.cfm" scrolling="no" width="100%" height="<cfoutput>#client.screenHeight#</cfoutput>"></iframe>
        </td>
      </tr>
    </table>
  <cfinclude template="/#application.maprootdir#/commonfiles/cf_tab_end.cfm">
  <cfinclude template="/#application.maprootdir#/commonfiles/showhide.cfm">
</body>
</html>