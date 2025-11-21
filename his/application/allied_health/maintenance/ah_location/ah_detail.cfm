<html>
<head>
	<title>Allied Health Detail Page</title>
</head>
<cfinclude template="/#application.maprootdir#/commonfiles/cfm_udf_common.cfm">

<cfif isDefined("form.BTNSAVE")>  
  <cftry>                
    <cfif isDefined("form.upd_flg") and form.upd_flg EQ "N">   
      <!--- check if category and location type duplicate --->         
      <cfquery name="qry_duplicate" datasource="#application.dataSource#" dbtype="#application.dbType#">
        SELECT AH.AHL_ID,
               AH.CID,
               LOC.LOCATION_ID,
               LOC.LOCATION_CODE              
          FROM NH_AHL AH, NH_LOCATION LOC, NH_CATEGORY CAT
         WHERE AH.LID = LOC.LOCATION_ID
           AND AH.CID = CAT.CATEGORY_ID
           AND CAT.ITEM_TYPE = 'AH'
           AND AH.CID = <cfqueryparam value="#form.ah_category#" cfsqltype="CF_SQL_NUMERIC">
           AND LOC.LOCATION_ID = <cfqueryparam value="#form.location#" cfsqltype="CF_SQL_NUMERIC">
           AND LOC.COMPANY_ID = <cfqueryparam value="#client.company_id#" cfsqltype="CF_SQL_NUMERIC">
      </cfquery>
      
      <cfif isDefined("qry_duplicate") and qry_duplicate.recordCount GT 0>
        <script>showMessage("PSS-00121")</script>
      <cfelse>
        <!--- Insert --->
        <cfquery name="qry_id" datasource="#application.dataSource#" dbtype="#application.dbType#">
          SELECT NH_AHL_SEQ.NEXTVAL AS ID FROM DUAL
        </cfquery>
   
        <cfquery name="insert_record" datasource="#application.dataSource#" dbtype="#application.dbType#">
          INSERT INTO NH_AHL
            (AHL_ID,
             CID,
             LID,
             IDT,
             USER_CREATE,
             USER_UPDATE,
             DATE_CREATE,
             DATE_UPDATE,
             LOCATION_CREATE,
             LOCATION_UPDATE)
          VALUES
            (<cfqueryparam value="#qry_id.ID#" cfsqltype="CF_SQL_NUMERIC">,
             <cfqueryparam value="#form.ah_category#" cfsqltype="CF_SQL_NUMERIC">,
             <cfqueryparam value="#form.location#" cfsqltype="CF_SQL_NUMERIC">,
             <cfif isDefined("form.ah_inac_date") and form.ah_inac_date NEQ "">
              <cfqueryparam value="#nhParseDate(form.ah_inac_date)#" cfsqltype="CF_SQL_DATE">,
             <cfelse>
              NULL,
             </cfif>
             <cfqueryparam value="#client.user_name#" cfsqltype="CF_SQL_VARCHAR">,
             <cfqueryparam value="#client.user_name#" cfsqltype="CF_SQL_VARCHAR">,
             SYSDATE,
             SYSDATE,
             <cfqueryparam value="#client.location#" cfsqltype="CF_SQL_VARCHAR">,
             <cfqueryparam value="#client.location#" cfsqltype="CF_SQL_VARCHAR">)
        </cfquery>   
        <!--- refresh the ah_form.cfm to clear the id --->
        <script>
          parent.form_frame.location.href = "ah_form.cfm";
        </script>        
      </cfif>
    <cfelse>          
      <cfquery name="update_record" datasource="#application.dataSource#" dbtype="#application.dbType#"> 
        UPDATE NH_AHL
           SET CID = <cfqueryparam value="#form.ah_category#" cfsqltype="CF_SQL_NUMERIC">,
               LID = <cfqueryparam value="#form.location#" cfsqltype="CF_SQL_NUMERIC">,
               <cfif isDefined("form.ah_inac_date") and form.ah_inac_date NEQ "">
                IDT = <cfqueryparam value="#nhParseDate(form.ah_inac_date)#" cfsqltype="CF_SQL_DATE">,
               <cfelse>
                IDT = NULL,
               </cfif>
               USER_CREATE = <cfqueryparam value="#client.user_name#" cfsqltype="CF_SQL_VARCHAR">,
               USER_UPDATE = <cfqueryparam value="#client.user_name#" cfsqltype="CF_SQL_VARCHAR">,
               DATE_CREATE = SYSDATE,
               DATE_UPDATE = SYSDATE,
               LOCATION_CREATE = <cfqueryparam value="#client.location#" cfsqltype="CF_SQL_VARCHAR">,
               LOCATION_UPDATE = <cfqueryparam value="#client.location#" cfsqltype="CF_SQL_VARCHAR">
         WHERE AHL_ID = <cfqueryparam value="#form.ahl_id#" cfsqltype="CF_SQL_NUMERIC">             
      </cfquery>                 
    </cfif>               
    <script>        
      parent.form_frame.ah_form.btnDelete.disabled = true;
      parent.form_frame.ah_form.btnNew.disabled = false;
      parent.form_frame.ah_form.btnSave.disabled = false;               
      parent.form_main.btn_search.click();             
    </script> 
    <cfcatch type="Any">
      <script>
        <cfoutput>
          showMessageStatic("Error Type: #cfcatch.type# \r\nMessage: #cfcatch.message#");
        </cfoutput>
      </script>    
    </cfcatch> 	
  </cftry>
</cfif>

<cfif isdefined("form.btnDelete")>
  <cftry>  
    <cfquery name="delete_record" datasource="#application.dataSource#" dbtype="#application.dbType#">
      DELETE NH_AHL
       WHERE AHL_ID = <cfqueryparam value="#form.ahl_id#" cfsqltype="CF_SQL_NUMERIC">        
    </cfquery>    
    <script>
      parent.form_frame.ah_form.btnNew.disabled = false;
      parent.form_frame.ah_form.btnDelete.disabled = true;
      parent.form_frame.ah_form.btnSave.disabled = false;      
    </script> 
    <cfcatch type="Any">
      <script>
        <cfoutput>
          showMessageStatic("Error Type: #cfcatch.type# \r\nMessage: #cfcatch.message#");
        </cfoutput>
      </script>    
    </cfcatch>	
  </cftry>   
</cfif>
  
<cfquery name="sel_ah" datasource="#application.datasource#" dbtype="#application.dbtype#">
  SELECT AH.AHL_ID,
         AH.CID,
         B.LOCATION_ID,
         B.LOCATION_CODE,
         AH.IDT,
         B.NAME,
         CAT.SEGMENT1,
         A.LOCATION_TYPE_CODE LOCATION_TYPE_GROUP_CODE
    FROM NH_LOCATION A, NH_LOCATION B, NH_AHL AH, NH_CATEGORY CAT
   WHERE A.LOCATION_ID = B.PARENT_LOCATION_ID
     AND B.LOCATION_ID = AH.LID
     AND AH.CID = CAT.CATEGORY_ID
     AND A.LOCATION_TYPE_CODE IN
         ('AH-PODIATRY', 'AH-PHYSIO', 'AH-OCC', 'AH-DIET')
     AND A.COMPANY_ID = <cfqueryparam value="#client.company_id#" cfsqltype="CF_SQL_NUMERIC">
     <cfif isDefined("form.ah_category") and form.ah_category NEQ "">
      AND AH.CID = <cfqueryparam value="#form.ah_category#" cfsqltype="CF_SQL_NUMERIC">
     </cfif> 
     <cfif isDefined("form.ah_code") and form.ah_code NEQ "">
      AND UPPER(B.LOCATION_CODE) = <cfqueryparam value="#ucase(form.ah_code)#" cfsqltype="CF_SQL_VARCHAR">
     </cfif>
     <cfif isDefined("form.ah_desc") and form.ah_desc NEQ "">
      AND UPPER(B.NAME) LIKE <cfqueryparam value="#ucase(ParseQuerySearchParam(form.ah_desc))#" cfsqltype="CF_SQL_VARCHAR">
     </cfif>
    ORDER BY CAT.SEGMENT1
</cfquery>

<body class="body0">
<form name="form_detail" action="" method="post">
<div class="GRID_PANEL" style="width:100%;height:<cfoutput>#client.screenHeight - 175#</cfoutput>;">
<table width="100%" border="1" cellpadding="0" cellspacing="0" class="GRID">
  <tr class="GRID_HEAD">
    <th class="th_color" width="15%"><cfoutput>#application.asc_symbol#</cfoutput><cfoutput>#udf_translate("Service Type", "AH", "")#</cfoutput></th>
    <th class="th_color" width="15%"><cfoutput>#udf_translate("Location Code", "AH", "")#</cfoutput></th>
    <th class="th_color" width="55%"><cfoutput>#udf_translate("Description", "AH", "")#</cfoutput></th>
    <th class="th_color" width="15%"><cfoutput>#udf_translate("Inactive Date", "AH", "")#</cfoutput></th>    
  </tr>
  <cfset alt_color = "Y">   
  <cfif isDefined("sel_ah") and sel_ah.recordCount GT 0>
    <cfoutput query="sel_ah">
      <cfif alt_color eq "Y">
        <cfset alt_color = "N">
        <cfset cls_name = "GRID_ALT_ROW">
      <cfelse>
        <cfset alt_color = "Y">
        <cfset cls_name = "GRID_ROW">
      </cfif>
      <tr id="row#currentrow#" class="#cls_name#" onmouseover="mouseOverSelected(this);style.cursor='hand';" onmouseout="mouseOutSelected(this);"
          onclick="mOvr(this,#sel_ah.currentrow#);chkclass(#AHL_ID#, #CID#, '#NAME#', '#nhDateFormat(IDT)#', #LOCATION_ID#, '#LOCATION_TYPE_GROUP_CODE#', '#SEGMENT1#');">
        <td class="GRID_CELL">#SEGMENT1#&nbsp;</td>
        <td class="GRID_CELL">#LOCATION_CODE#&nbsp;</td>
        <td class="GRID_CELL">#NAME#&nbsp;</td> 
        <td class="GRID_CELL">#nhDateFormat(IDT)#&nbsp;</td>
      </tr>
    </cfoutput>
  <cfelse>
    <tr>
      <td colspan="4" class="GRID_CELL" align="center">
        <cfoutput>#udf_translate("No Record Found", "System", "")#</cfoutput>.
      </td>
    </tr>    
  </cfif> 
  <input type="hidden" name="ahl_id">
  <input type="hidden" name="ah_category">
  <input type="hidden" name="ah_loc_type">
  <input type="hidden" name="location">
  <input type="hidden" name="ah_inac_date">
  <input type="hidden" name="upd_flg" value="N">
  <input type="hidden" name="hidden_code">
  <input type="submit" class="button_db_op" name="btnSave" style="display:none;" value="<cfoutput>#udf_translate('Save', 'System', 'BUTTON_LABEL')#</cfoutput>(F2)">
  <input type="submit" class="button_db_op" name="btnDelete" style="display:none;" value="<cfoutput>#udf_translate('Delete', 'System', 'BUTTON_LABEL')#</cfoutput>(F2)">    
</table>
</div>
<input type="Hidden" value="" name="hRowClass">
<input type="Hidden" value="" name="hRowIDClicked">
</form>
</body>
<script>
  function chkclass(ah_id, category_id, location_name, inactive_date, location_id, location_type_group_code, hidden_location)
  {                
    parent.form_frame.ah_form.ah_category.value = category_id;
    parent.form_frame.ah_form.ah_loc_type.value = location_name;
    parent.form_frame.ah_form.ah_inac_date.value = inactive_date;
    parent.form_frame.ah_form.location.value = location_id;
    parent.form_frame.ah_form.hidden_code.value = location_type_group_code;
    parent.form_frame.ah_form.btnDelete.disabled = false;
    parent.form_frame.ah_form.hidden_location.value = location_name;
    document.form_detail.ahl_id.value = ah_id;
    document.form_detail.upd_flg.value = "Y";               
    
  }
  
  var count = 0;
  var tempIdx;
  function mOvr(src,rowIdx){ 
    document.form_detail.hRowIDClicked.value = src.id;
    if (!src.contains(event.fromElement)){
      src.style.cursor = 'hand'; 
        src.className = "GRID_SELECTION";
      }
      if(count!=0){
        if(temp != src){
          if(!temp.contains(event.toElement)){
            temp.style.cursor = 'default';
            if ((parseInt(tempIdx,10)%2) == 0){
                temp.className = "GRID_ROW";
            }else{
                temp.className = "GRID_ALT_ROW";
  
            }
          }
        }
      }
    temp=src;
    tempIdx=rowIdx;
    count++;
  }
  
  function mouseOverSelected(obj) 
  {
    if(obj.className != "GRID_SELECTION") 
    {
      document.form_detail.hRowClass.value = obj.className;
      obj.className = "GRID_SELECTION";
    }
  }
  
  function mouseOutSelected(obj) 
  {
    var vRowClass = document.form_detail.hRowClass.value;
    var vRowIDClicked = document.form_detail.hRowIDClicked.value;
    if(obj.id != vRowIDClicked) 
    {
      if(vRowClass != "GRID_ROW") 
      {
        obj.className = "GRID_ALT_ROW";
      }
      else 
      {
        obj.className = "GRID_ROW";
      }
    }
  }
</script>  
</html>
 