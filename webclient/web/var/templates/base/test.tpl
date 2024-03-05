{*
 * $Copyright-Start$
 * @copyright Copyright &copy; 2005 RedPrairie Corporation - All Rights Reserved
 * $Copyright-End$
 *
 * test.tpl
 * @author Brandon Grady <brandon.grady@redprairie.com>
 * This is a test template.
 *}

{* Before we do anything, generate the nav-bar menu *}
{include_php file="file:$waffle_dir/$template_dir/includes/generate_nav_menu.inc.php"}

<html>
    <head>
        {include file="file:$waffle_dir/$template_dir/includes/header.tpl" alternate_title='DigitaLogistix'}
    </head>

    <body>
        {include file="file:$waffle_dir/$template_dir/includes/page_top.tpl" alternate_title='DigitaLogistix&reg;'}

        <h1>The VAR level works!</h1>

        {include file="file:$waffle_dir/$template_dir/includes/page_bottom.tpl"}
    </body>

</html>
