<html>
<head>
	<title>Allied Health Main Page</title>
</head>

<cfquery name="sel_category" datasource="#application.datasource#" dbtype="#application.dbtype#">
  SELECT CATEGORY_ID, ITEM_TYPE, TYPE, CATEGORY_CODE, GLOBAL_SEGMENT, SEGMENT1
    FROM NH_CATEGORY
   WHERE ITEM_TYPE = 'AH'
     AND SYSTEM_FLG = 'Y'
   ORDER BY GLOBAL_SEGMENT ASC
</cfquery>  

<body class="body0">
<form name="form_main" action="ah_detail.cfm" method="post" target="detail_frame">
<cfset table_width = "100%">
<cfset table_height = "20">
<cfset table_align = "left">
<cfset table_title = "#udf_translate('AH Location Details', 'AH', 'Table_Title')#">
<cfinclude template="/#application.maprootdir#/commonfiles/cf_table.cfm">
<table border="0" width="100%" cellpadding="1" cellspacing="1" class="bg_color">
  <tr>
    <td width="25%">
      <cfoutput>#udf_translate("Type", "AH", "")#</cfoutput>:&nbsp;&nbsp;
      <select name="ah_category" style="width:150px">      	
        <option value="">--All--</option>
        <cfoutput query="sel_category">
      	  <option value="#CATEGORY_ID#">#SEGMENT1#</option>
        </cfoutput>
      </select>   
    </td>
    <td width="35%">
      <cfoutput>#udf_translate("Location Code", "AH", "")#</cfoutput>:&nbsp;&nbsp;   
      <input type="Text" name="ah_code" class="in" size="15" maxlength="50" onkeyup="validateSpecialCharacters(this, document.form_main.special_chars, 'Y', 'Y');"
             onblur="validateSpecialCharacters(this, document.form_main.special_chars, 'Y', 'Y');">
      <input type="hidden" name="special_chars" value=" !@#$%^&*+=;:><?/\|~`[]{},.?">               
    </td>
    <td width="30%">
      <cfoutput>#udf_translate("Description", "AH", "")#</cfoutput>:&nbsp;&nbsp;   
      <input type="Text" name="ah_desc" class="in" size="35" maxlength="200">      
    </td>
    <td align="right">
      <input type="Submit" class="button_db_op" name="btn_search" value="<cfoutput>#udf_translate("Search", "AH", "")#</cfoutput>">
    </td>
  </tr>
  <tr>
    <td colspan="4">
      <cfset detail_height = client.screenHeight - 175>
      <iframe name="detail_frame" frameborder="0" src="ah_detail.cfm" scrolling="no" width="100%" height="<cfoutput>#detail_height#</cfoutput>"></iframe>   
    </td>
  </tr>
  <tr>
    <td colspan="4">
      <iframe name="form_frame" frameborder="0" src="ah_form.cfm" scrolling="no" width="100%" height="47"/>
    </td>
  </tr> 
</table>
<cfinclude template="/#application.maprootdir#/commonfiles/cf_table_bottom.cfm">
</form>
</body>
</html>
