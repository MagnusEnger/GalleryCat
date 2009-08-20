
// Clicked on an image, display it above
function imageClick(e) {

    var image_id = $(this).attr('imgid');
    if ( GC_current_image != image_id ) {
        activateImage( image_id );
    }
    return false;
}

function prevImage(e) {
    return activateImage( GC_current_image - 1 );
}

function nextImage(e) {
    return activateImage( GC_current_image + 1 );
}

function activateImage( image_id ) {

    image_id = parseInt(image_id);  // Fixes odd issue where image_id is sometimes treated as a string
    
    // delete previous picture
    $('#gallery #image img').animate({opacity: 0.0}, GC_fade_speed, 'linear', function() {
        jQuery(this).remove();
    });

    // Get image info
    var image_div = $('#gallery #image');
    var image_container = $('#gallery #image-container');
  
    var image = GC_images[image_id];
    var height = image[3] > image_div.innerHeight() ? image_div.innerHeight() : image.height;

    // If the image is going to be resized, we need to recalculate its width
    var resize_prc = GC_max_height / image.height;
    var width = resize_prc < 1 ? ( image.width * resize_prc ) : image.width;

    // append new picture
    new_img = jQuery('<img />')
        .attr('src', image.url)
        .css({
            position: 'absolute',
            top: 0,
            height: height,
            opacity: 0.0,
            left: (image_container.innerWidth() - width) / 2
        })
        .appendTo('#gallery #image-container')
        .animate({opacity: 1.0}, GC_fade_speed, 'linear');
        
    
        
     GC_current_image = image_id;

    // Show and hide relevant controls

    if ( image_id <= 0 ) {
        $('#gallery #previous-image a').hide();
    }
    else {
        $('#gallery #previous-image a').show();
    }

    if ( image_id >= (GC_images.length-1) ) {
        $('#gallery #next-image a').hide();
    }
    else {
        $('#gallery #next-image a').show();
    }
    
    // Preload some images
    
    if ( image_id > 0 ) { preload( image_id-1 ); }
    if ( image_id < (GC_images.length-1) ) { preload( image_id+1 ); }

    return false;
}


function changePage( add ) {
    var previous_page = GC_current_page;
    GC_current_page += add;
    if ( GC_current_page < 0 ) { GC_current_page = 0; }
    if ( GC_current_page > GC_max_page ) { GC_current_page = GC_max_page; }
    if ( GC_current_page == previous_page ) { return false; }

    if ( GC_current_page == 0 ) {
        $('#gallery #navigation #first-page a').hide();
        $('#gallery #navigation #previous-page a').hide();
    }
    else {
        $('#gallery #navigation #first-page a').show();
        $('#gallery #navigation #previous-page a').show();
    }

    if ( GC_current_page == GC_max_page ) {
        $('#gallery #navigation #next-page a').hide();
        $('#gallery #navigation #last-page a').hide();
    }
    else {
        $('#gallery #navigation #next-page a').show();
        $('#gallery #navigation #last-page a').show();
    }

    // Set all the images in the thumbnails.  This would be way nicer by creating a new page
    // and sliding it in...

    var image_id = GC_current_page*GC_thumbnails;
    for ( var x=0; x<GC_thumbnails; x++ ) {
        var link = $('#gallery #navigation #nav-' + x + ' a');
        var img = link.find('img');
        
        if ( image_id >= GC_images.length ) {
            link.attr('imgid', -1).hide();
        }
        else {
            img.attr('src', GC_images[image_id].thumbnail)
            link.attr('imgid', image_id).show();
        }
        image_id++;
    }

    return false;
}

function preload(image_id) {
    var image = GC_images[image_id];
    if ( typeof(image) == 'undefined' || image.preloaded ) {
        return;
    }

    jQuery('<img />')
        .hide()
        .attr('src', image.url)
        .appendTo(document.body)
        .load(function () { image.preloaded = true; jQuery(this).remove(); })
        .error(function () { jQuery(this).remove(); });
}

$(document).ready( function() {
    $('#gallery #navigation .navigation-block a').bind('click', imageClick);
    $('#gallery #previous-image a').bind('click', prevImage);
    $('#gallery #next-image a').bind('click', nextImage);
    $('#gallery #first-page a').bind('click', function() { changePage(-GC_max_page) });
    $('#gallery #previous-page a').bind('click', function() { changePage(-1) });
    $('#gallery #next-page a').bind('click', function() { changePage(1) });
    $('#gallery #last-page a').bind('click', function() { changePage(GC_max_page) });
    preload( GC_current_image + 1 );
});



