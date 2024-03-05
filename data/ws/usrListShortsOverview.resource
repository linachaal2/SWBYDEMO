<resource>
  <id>usrListShortsOverview</id>
  <name>Shorts summary</name>
  <description>Shorts summary</description>
  <properties>
    <property name="rplref" type="string" pk="true" description="Replenishment reference"/>
    <property name="marked" type="string" description="Marked"/>
    <property name="ordnum" type="string" description="Order number"/>
    <property name="ordlin" type="string" description="Order line"/>
    <property name="wkonum" type="string" description="Work Order number"/>
    <property name="wkolin" type="string" description="Work Order line"/>
    <property name="schbat" type="string" description="Schedule batch"/>
    <property name="pckqty" type="int" description="Pick Quantity"/>
    <property name="prtnum" type="string" description="Item number"/>
    <property name="item_desc" type="string" description="Item description"/>
    <property name="lotnum" type="string" description="Lot number"/>
    <property name="ordtyp" type="string" description="Order Type"/>
    <property name="ordqty" type="int" description="Ordered Quantity"/>
    <property name="ordtyp_desc" type="string" description="Order Type description"/>
    <property name="rsncod" type="string" description="Reason code"/>
    <property name="rsncod_desc" type="string" description="Reason code description"/>
    <property name="rsndtl" type="string" description="Reason details"/>
    <property name="early_shpdte" type="datetime" description="Early Ship Date"/>	
    <property name="late_shpdte" type="datetime" description="Late Ship Date"/>	
    <property name="reallocateflag" type="int" description="Reallocate"/>
  </properties>
<actions>
	<action type= "list" ref="usrListShortsOverview"/>
    <action type= "action" ref="usrMarkShorts"/>
    <action type= "action" ref="usrUnmarkShorts"/>
    <action type= "action" ref="usrCancelShort"/>
    <action type= "action" ref="usrCancelShortReallocate"/>
</actions>
</resource>