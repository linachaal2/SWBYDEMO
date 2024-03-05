<resource>
   <id>usrGLNLocation</id>
   <name>usrGLNLocation</name>
   <description>GLN Location</description>
   <properties>
      <property name="gln" type="string" description="GLN" pk="true"/>
	  <property name="stoloc" type="string" description="Location"/>
	  <property name="uc_sort_out_id" type="int" description="Station number"/>
   </properties>
   <actions>
      <action type="list" ref="usrListGLNLocation"/>
      <action type="add" ref="usrAddGLNLocation"/>
      <action type="edit" ref="usrEditGLNLocation"/>
      <action type="delete" ref="usrDeleteGLNLocation"/> 
   </actions>
</resource>
