<resource>
  <id>usrListShortLocations</id>
  <name>Locations for short</name>
  <description>Locations with inventory matching short</description>
  <properties>
    <property name="stoloc" type="string" description="Location"/>
    <property name="useflg" type="int" description="Usable"/>
    <property name="pckflg" type="int" description="Pickable"/>
    <property name="locsts" type="string" description="Location status"/>
    <property name="untqty" type="int" description="Quantity on LPN"/>
    <property name="lodnum" type="string" description="LPN" pk="true"/>
    <property name="prtnum" type="string" description="Item number" pk="true"/>
    <property name="lotnum" type="string" description="Lot number" pk="true"/>
  </properties>
    <actions>
        <action type= "list" ref="usrListShortLocations"/>
    </actions>
</resource>