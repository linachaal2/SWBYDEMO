<resource>
   <id>usrDeliveryPickhop</id>
   <name>usr_Delivery_Pickhop</name>
   <description>Delivery Pickhop Setup</description>
   <properties>
	  <property name="uc_delivery_id" type="int" pk="true" description="Delivery ID"/>
	  <property name="dst_mov_zone_id" type="int" pk="true" description="Destination Movement Zone ID"/>
	  <property name="seqnum" type="int" pk="true" description="Sequence"/>
	  <property name="stoloc" type="string" description="Location"/>
	  <property name="lngdsc" type="string" description="Movement Zone"/>
   </properties>
   <actions>
      <action type="list" ref="usrListDeliveryPickhop"/>
      <action type="add" ref="usrAddDeliveryPickhop"/>
      <action type="edit" ref="usrEditDeliveryPickhop"/>
      <action type="delete" ref="usrDeleteDeliveryPickhop"/> 
   </actions>
</resource>
