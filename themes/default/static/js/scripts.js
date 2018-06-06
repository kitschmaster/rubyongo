jQuery(function($) {

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
        /*ga('send', {
          hitType: 'event',
          eventCategory: 'RokaviceBasket',
          eventAction: 'add',
          eventLabel: item.name
        });*/
    });
    simpleCart.bind( 'beforeCheckout' , function(item){
        /*ga('send', {
          hitType: 'event',
          eventCategory: 'RokaviceBasket',
          eventAction: 'order',
          eventLabel: item.name
        });*/
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
