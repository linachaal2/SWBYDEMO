<?php

/**
 * $Copyright-Start$
 * @copyright Copyright &copy; 2005 RedPrairie Corporation - All Rights Reserved
 * $Copyright-End$
 *
 * test.inc.php
 * @author Brandon Grady <brandon.grady@redprairie.com>
 * This model is a test model.
 *
 * This is a passive model that results in launching the usr|test view.
 */

$debug->add_debug_message('Entering the USR|TEST mode.', DEBUG_MSG_TYPE_TRC,  __FILE__, __LINE__);

// Assign the template variables
$view = 'usr|test';
// Set the FORM Id as the view.
$util->set_mcs_form($view);
$tpl->assign('title', $util->get_mls_text('ttlDefault'));
$tpl->assign('page_name', 'test');

?>
