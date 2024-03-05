/**
 * Define our Sample TaskForm object using its fully-qualified name.
 *
 * This taskForm extends RP.chrome.task.TaskForm
 */
Ext.define('LES.sample.VersionsApp', {
  extend: 'RP.chrome.task.TaskForm',

  initComponent: function() {

    Ext.define('LibraryVersion', {
      extend: 'Ext.data.Model',
      idProperty: 'library_name',
      fields: ['product', 'library_name', 'package_name', 'category', 'version']
    });

    /**
     * Applying ExtJs config options to this taskform
     */
    Ext.apply(this, {
      title: RP.getMessage('rp.services.versionTask.welcome'),
      /**
       * Add items to this taskform
       */
      items: [
        Ext.create('Ext.grid.Panel', {
          columns: {
            items: [{
              header: RP.getMessage('rp.services.versionTask.product'),
              flex: 1,
              dataIndex: 'product'
            }, {
              header: RP.getMessage('rp.services.versionTask.library'),
              flex: 1,
              dataIndex: 'library_name'
            }, {
              header: RP.getMessage('rp.services.versionTask.package'),
              flex: 2,
              dataIndex: 'package_name'
            }, {
              header: RP.getMessage('rp.services.versionTask.category'),
              flex: 1,
              dataIndex: 'category'
            }, {
              header: RP.getMessage('rp.services.versionTask.version'),
              flex: 1,
              dataIndex: 'version'
            }]
          },
          store: Ext.create('Ext.data.Store', {
            model: 'LibraryVersion',
            proxy: {
              type: 'ajax',
              api: {
                read: RP.buildDataServiceUrl('wm', 'listVersions')
              },
              reader: {
                type: 'json',
                root: 'data'
              }
            },
            autoLoad: true
          }),
          height: 750
        })
      ]

    });

    this.callParent();
  }

});