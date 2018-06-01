jQuery(function($) {

    /* ============================================================ */
    /* Responsive Videos */
    /* ============================================================ */

    $(".post-content").fitVids();

    /* ============================================================ */
    /* Scroll To Top */
    /* ============================================================ */

    $('.js-jump-top').on('click', function(e) {
        e.preventDefault();

        $('html, body').animate({'scrollTop': 0});
    });

    var simpleCartURL = "http://localhost:8080/w/o";
    var simpleCartRedirectURL = "http://localhost:8080/w/d";
    if (woURL !== undefined) {
        simpleCartURL = woURL;
    }
    if (woRedirectURL !== undefined) {
        simpleCartRedirectURL = woRedirectURL;
    }


    //get JWT token if not yet having one

    simpleCart({
        checkout: {
            type: "SendForm" ,
            url: simpleCartURL,
            method: "POST",
            extra_data: {
                redirect_url: simpleCartRedirectURL
                //send jwt token with the post
            }
        },
        cartStyle: 'table'
    });

    simpleCart.bind( 'afterAdd' , function( item ){
        //alert( item.name + " has been added to the cart!");
    });
    simpleCart.bind( 'beforeCheckout' , function(){
        alert( "Success!");
    });

    var dialog = $('div.simpleCart_dialog');

    $('a.simpleCart_toggle_button').on('click', function(e) {
        e.preventDefault();
        dialog.removeClass('hidden');
    });
    $('button.simpleCart_dialog_close').on('click', function() {
        dialog.addClass('hidden');
    });

});

hljs.initHighlightingOnLoad();
