<resource>
  <id>usrListReadyForListDetails</id>
  <name></name>
  <description>All tasks from locations where there is a Ready for list task</description>
  <properties>
    <property name="srcloc" type="string" description="Source Location"/>
    <property name="oprcod" type="string" description="Operation Code"/>
    <property name="pcksts" type="string" description="Pick Status"/>
    <property name="list_id" type="string" description="List Id"/>
    <property name="pckqty" type="int" description="Pick Quantity"/>
    <property name="picked_qty" type="int" description="Picked Quantity"/>  
    <property name="prtnum" type="string" description="Item Number"/>
    <property name="lotnum" type="string" description="Lot Number"/>
    <property name="schbat" type="string" description="Schedule Batch"/>
    <property name="ship_id" type="string" description="Shipment"/>
    <property name="ordnum" type="string" description="Order Number"/>
    <property name="rtcust" type="string" description="Route-to Customer"/>
    <property name="early_shpdte" type="datetime" description="Minumum Early Ship Date"/>
    <property name="late_shpdte" type="datetime" description="Minumum Late Ship Date"/>
    <property name="effpri" type="int" description="Priority"/> 
  </properties>
<actions>
	<action type= "list" ref="usrListReadyForListDetails"/>
</actions>
</resource>