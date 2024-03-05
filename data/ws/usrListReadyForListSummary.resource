<resource>
  <id>usrListReadyForListSummary</id>
  <name>Tasks in Ready For List status summary</name>
  <description>Tasks in Ready For List status summary</description>
  <properties>
    <property name="srcloc" type="string" pk="true" description="Source Location"/>
    <property name="pcksts" type="string" description="Pick Status"/>
    <property name="pckqty" type="int" description="Pick Quantity"/>
    <property name="open_lists" type="int" description="Number of Open Lists"/>  
    <property name="picked_qty" type="int" description="Picked Quantity"/>  
    <property name="dstloc" type="string" description="Destination Location"/>
    <property name="ordtyp" type="string" description="Order Type"/>
    <property name="early_shpdte" type="datetime" description="Minumum Early Ship Date"/>
    <property name="late_shpdte" type="datetime" description="Minumum Late Ship Date"/>	
  </properties>
<actions>
	<action type= "list" ref="usrListReadyForListSummary"/>
</actions>
</resource>