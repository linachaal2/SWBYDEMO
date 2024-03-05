/**
 * Define our Sample TaskForm object using its fully-qualified name.
 *
 * This taskForm extends RP.chrome.task.TaskForm
 */
Ext.define('LES.sample.SampleApp', {
  extend: 'RP.chrome.task.TaskForm',

  initComponent: function() {

    /**
     * Applying ExtJs config options to this taskform
     */
    Ext.apply(this, {
      title: RP.getMessage('rp.customer.sampleTask.welcome'),
      /**
       * Add items to this taskform
       */
      items: [{
        xtype: 'box',
        html: '<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</p><br><br>'
      }, {
        xtype: 'chart',
        height: 400,
        width: 600,
        store: new Ext.data.ArrayStore({
          fields: ['x', 'y'],
          data: [
            [0, 1],
            [1, 2],
            [2, 1],
            [3, 3],
            [4, 2]
          ]
        }),
        axes: [{
          position: 'bottom',
          type: 'Category',
          grid: true,
          fields: ['x']
        }, {
          position: 'left',
          type: 'Numeric',
          fields: ['y'],
          minimum: 0,
          maximum: 3

        }],
        series: [{
          type: 'column',
          xField: 'x',
          yField: 'y',
          renderer: function(sprite, storeItem, barAttr, i, store) {
            barAttr.fill = '#0076AD';
            barAttr.opacity = 0.25;
            return barAttr;
          }
        }]
      }]
    });

    this.callParent();
  }

});