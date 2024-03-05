<resource>
   <id>usrDeliveryMultidrop</id>
   <name>usr_Delivery_Multidrop</name>
   <description>Delivery Multidrop Setup</description>
   <properties>
	  <property name="seqnum" type="int" pk="true" description="Sequence"/>
	  <property name="stoloc" type="string" description="Location"/>
	  <property name="frstol" type="string" description="From Location"/>
   </properties>
   <actions>
      <action type="list" ref="usrListDeliveryMultidrop"/>
      <action type="add" ref="usrAddDeliveryMultidrop"/>
      <action type="edit" ref="usrEditDeliveryMultidrop"/>
      <action type="delete" ref="usrDeleteDeliveryMultidrop"/> 
   </actions>
</resource>
