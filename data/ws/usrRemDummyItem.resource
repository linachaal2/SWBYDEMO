<resource>
  <id>usrRemDummyItem</id>
  <name>Opschonen karren met Hold/Dummy</name>
  <description>Opschonen karren met Hold/Dummy</description>
  <properties>
	<property name= "prtnum" type="string"/>
    <property name= "lodnum" type="string" pk="true"/>
	<property name= "asset_typ" type="string"/>
	<property name= "inv_attr_str8" type="string"/>
	<property name= "short_dsc" type="string"/>
	<property name= "stoloc" type="string"/>
  </properties>
<actions>
	<action type= "list" ref="usrListDummyItem"/>
	<action type= "delete" ref="usrDeleteDummyItem"/>
</actions>
</resource>