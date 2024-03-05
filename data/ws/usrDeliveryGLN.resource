<resource>
   <id>usrDeliveryGLN</id>
   <name>usr_Delivery_GLN</name>
   <description>GLN Setup</description>
   <properties>
      <property name="gln" type="string" description="GLN" pk="true"/>
	  <property name="uc_delivery_id" type="int" description="Delivery ID" pk="true"/>
   </properties>
   <actions>
      <action type="list" ref="usrListDeliveryGLN"/>
      <action type="add" ref="usrAddDeliveryGLN"/>
      <action type="edit" ref="usrEditDeliveryGLN"/>
      <action type="delete" ref="usrDeleteDeliveryGLN"/> 
   </actions>
</resource>
