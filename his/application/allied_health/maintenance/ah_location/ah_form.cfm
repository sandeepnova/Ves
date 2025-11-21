<html>
<head>
	<title>Allied Health Form Page</title>
</head>
<cfinclude template="/#application.maprootdir#/commonfiles/check_date.cfm">
<cfinclude template="/#application.maprootdir#/commonfiles/display_popup.cfm">

<cfquery name="sel_category" datasource="#application.datasource#" dbtype="#application.dbtype#">
  SELECT CATEGORY_ID, ITEM_TYPE, TYPE, CATEGORY_CODE, GLOBAL_SEGMENT, SEGMENT1
    FROM NH_CATEGORY
   WHERE ITEM_TYPE = 'AH'
     AND SYSTEM_FLG = 'Y'
   ORDER BY GLOBAL_SEGMENT ASC
</cfquery>   

<cfif isDefined("form.ah_category") and form.ah_category NEQ "">
  <cfquery name="get_category_code" datasource="#application.datasource#" dbtype="#application.dbtype#">
    SELECT CATEGORY_CODE
      FROM NH_CATEGORY
     WHERE ITEM_TYPE = 'AH'
       AND SYSTEM_FLG = 'Y'
       AND CATEGORY_ID = <cfqueryparam value="#form.ah_category#" cfsqltype="CF_SQL_NUMERIC">
  </cfquery>             
    <cfset where_clause = "AND A.LOCATION_TYPE_CODE IN ('" & #get_category_code.CATEGORY_CODE# & "') OR A.PARENT_LOCATION_ID IN (SELECT B.LOCATION_ID FROM NH_LOCATION B WHERE B.LOCATION_TYPE_CODE IN ('" & #get_category_code.CATEGORY_CODE# & "') AND B.COMPANY_ID = " & #client.company_id# & ") AND A.COMPANY_ID = " & #client.company_id# & "ORDER BY DISPLAY_POPUP_GROUP_CODE, PARENT_LOCATION_ID, NAME">
<cfelse>  
    <cfset where_clause = "AND A.LOCATION_TYPE_CODE IN (SELECT CAT.CATEGORY_CODE FROM NH_CATEGORY CAT WHERE CAT.ITEM_TYPE = '" & #application.Item_Type_AH# & "' AND CAT.SYSTEM_FLG = 'Y' AND CAT.SEGMENT2 IS NULL) OR A.PARENT_LOCATION_ID IN (SELECT B.LOCATION_ID FROM NH_LOCATION B WHERE B.LOCATION_TYPE_CODE IN (SELECT CAT.CATEGORY_CODE FROM NH_CATEGORY CAT WHERE CAT.ITEM_TYPE = '" & #application.Item_Type_AH# & "' AND CAT.SYSTEM_FLG = 'Y' AND CAT.SEGMENT2 IS NULL) AND B.COMPANY_ID = " & #client.company_id# & ") AND A.COMPANY_ID = " & #client.company_id# & "ORDER BY DISPLAY_POPUP_GROUP_CODE, PARENT_LOCATION_ID, NAME">
</cfif>
<body class="body0">
<form name="ah_form" method="post" action="ah_form.cfm">
<input type="hidden" name="wherestring2" value="<cfif isDefined('variables.where_clause') and variables.where_clause NEQ ""><cfoutput>#variables.where_clause#</cfoutput></cfif>">
<table border="0" width="100%" cellpadding="1" cellspacing="1" class="bg_color">
  <tr>
    <td width="12%">
      <cfoutput>#udf_translate("Category", "AH", "")#</cfoutput>*:
    </td>
    <td width="22%">        
      <select name="ah_category" style="width:150px" onchange="setTypeCode(this);">      	
        <option value="">--All--</option>
    		<cfoutput query="sel_category">
    	    <option value="#CATEGORY_ID#" <cfif isDefined("form.ah_category") and form.ah_category EQ CATEGORY_ID>selected</cfif>>#SEGMENT1#</option>
    		</cfoutput>
    	</select>                
    </td>          
    <td width="13%">
      <cfoutput>#udf_translate("Location Type", "AH", "")#</cfoutput>*:
    </td>
    <td>
      <input type="text" class="in_md" name="ah_loc_type" size="23" maxlength="200" onblur="searchlocation(this, 1);"><input type="button" value="6" class="button_act" name="" onclick="searchlocation(ah_loc_type, 2);">
      <input type="hidden" class="IN" name="location">
      <input type="hidden" class="IN" name="hidden_location"> 
      <input type="hidden" class="IN" name="hidden_code">         
    </td>        
  </tr>
  <tr>
    <td>
      <cfoutput>#udf_translate("Inactive Date", "AH", "")#</cfoutput>:
    </td>
    <td>
      <input type="text" name="ah_inac_date" maxlength="12" size="12" class="in" value="" onblur="check_date(this)"><input onclick="dates(ah_inac_date);" type="button" value="6" class="button_act">
    </td>
    <td align="right" colspan="4">
      <input type="button" class="button_db_op" name="btnNew" value="<cfoutput>#udf_translate('New', 'System', 'BUTTON_LABEL')#</cfoutput>" onclick="new_record();parent.detail_frame.form_detail.upd_flg.value = 'N';document.ah_form.btnDelete.disabled = true;">
      <input type="button" class="button_db_op" name="btnDelete" value="<cfoutput>#udf_translate('Delete', 'System', 'BUTTON_LABEL')#</cfoutput>" onclick="checkButton();" disabled>
      <input type="button" class="button_db_op" name="btnSave" value="<cfoutput>#udf_translate('Save', 'System', 'BUTTON_LABEL')#</cfoutput>(F2)" onclick="checkData();">        
    </td>
  </tr>
</table>   
</form>
</body>
<script>
  document.onkeydown=checkEvent;
  function checkEvent()
  {
    var ieKey = window.event.keyCode;
    if (ieKey==113) //press F2
      document.ah_form.btnSave.click();
  }
  
  function setTypeCode(type_code)
  {    
    parent.detail_frame.form_detail.upd_flg.value = "N"
    document.ah_form.submit();        
  }
  
  function checkData()
  {    
    if (document.ah_form.ah_category.value == "")
    {
      showMessage("NH-00151");
      document.ah_form.ah_category.focus();
      return false;
    }    
    if (document.ah_form.ah_loc_type.value == "")
    {
      showMessage("MNT-00069");
      document.ah_form.ah_loc_type.focus();
      return false;
    }    
    
    if (document.ah_form.ah_inac_date.value != '')
    {
      <cfoutput>
      if (datecomp_js('#nhdateformat(now())#', document.ah_form.ah_inac_date.value) < 0)
      {
    	  showMessage("NH-00240");        
        document.ah_form.ah_inac_date.focus();
        return false;
      }
      </cfoutput>
    }
    
    parent.detail_frame.form_detail.ah_category.value = document.ah_form.ah_category.value;
    parent.detail_frame.form_detail.ah_loc_type.value = document.ah_form.ah_loc_type.value;
    parent.detail_frame.form_detail.location.value = document.ah_form.location.value;   
    parent.detail_frame.form_detail.ah_inac_date.value = document.ah_form.ah_inac_date.value;
    parent.detail_frame.form_detail.hidden_code.value = document.ah_form.hidden_code.value;    
    document.ah_form.btnSave.disabled = true;
    document.ah_form.btnNew.disabled = true;
    document.ah_form.btnDelete.disabled = true;
    new_record();
    parent.detail_frame.form_detail.btnSave.click();  
  }
  
  function searchlocation(obj,chk)
  { 
    <cfoutput>
      var frm=document.ah_form;
      var tablelist="NH_LOCATION A";
      var desc="A.NAME, A.LOCATION_ID, NVL(A.PARENT_LOCATION_ID, 0)  PARENT_LOCATION_ID, (NVL((SELECT LOCATION_TYPE_CODE FROM NH_LOCATION WHERE LOCATION_ID = A.PARENT_LOCATION_ID), A.LOCATION_TYPE_CODE)) DISPLAY_POPUP_GROUP_CODE"
      
      //check whether the source come from textbox, if yes, it could not be the same value and empty
      if(!((frm.ah_loc_type.value == "" || frm.ah_loc_type.value == frm.hidden_location.value) && chk == 1))
      {				
        if(chk == 1)
        {
          poplist2('ah_form', obj, 'location', '', tablelist, 'A.LOCATION_ID', desc, 'Location', 1, 1, '', 0, escape(document.ah_form.wherestring2.value));	
        }
        else
        {  
          //choosing from detail
          if (parent.detail_frame.form_detail.upd_flg.value == 'Y')
          {                           
            if (document.ah_form.hidden_code.value != "")
            {          
              var where_clause = "AND A.LOCATION_TYPE_CODE IN ('" + document.ah_form.hidden_code.value +"') OR A.PARENT_LOCATION_ID IN (SELECT B.LOCATION_ID FROM NH_LOCATION B WHERE B.LOCATION_TYPE_CODE IN ('" + document.ah_form.hidden_code.value +"') AND B.COMPANY_ID = #client.company_id#) AND A.COMPANY_ID = #client.company_id# ORDER BY DISPLAY_POPUP_GROUP_CODE, PARENT_LOCATION_ID, NAME";
            }
            else
            {           
              var where_clause = escape(document.ah_form.wherestring2.value);
            }
            poplist2('ah_form', obj.name, 'location', '', tablelist, 'A.LOCATION_ID', desc, 'Location', 1, 1, '', 0, escape(where_clause));	  					                
          }
          else
          {
            poplist2('ah_form', obj.name, 'location', '', tablelist, 'A.LOCATION_ID', desc, 'Location', 1, 1, '', 0, escape(document.ah_form.wherestring2.value));	  					                
          }        
        }
        frm.hidden_location.value=frm.ah_loc_type.value;	
      }  
    </cfoutput>
  }
  
  
  function new_record()
  {         
    document.ah_form.ah_category.value = "";
    document.ah_form.ah_category.focus();
    document.ah_form.ah_loc_type.value = "";
    document.ah_form.ah_loc_type.className = "in_md";
    document.ah_form.ah_inac_date.value = ""; 
    document.ah_form.location.value = ""; 
    document.ah_form.hidden_location.value = "";    
    document.ah_form.hidden_code.value = "";   
  }
  
  function checkButton()
  {    
    document.ah_form.btnSave.disabled = true;
    document.ah_form.btnNew.disabled = true;
    document.ah_form.btnDelete.disabled = true;   
    new_record();
    parent.detail_frame.form_detail.btnDelete.click();  
  }
</script>
</html>
 