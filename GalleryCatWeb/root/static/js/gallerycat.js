var GalCat = function() {
    var private = {
        current_image: 0,
        current_page: 0,
        text_focus: false,
    };
    
    var public = {
        max_height: 400, 
        fade_speed: 500,
        slide_speed: 500,
        images: [],
        thumbnails: [],
        thumbnails_per_page: 5,
        thumbnail_width: 100,
        thumbnail_height: 100,

        //
        //
        //

        activateImage: function( image_index ) {

            image_index = parseInt(image_index);  // Fixes odd issue where image_index is sometimes treated as a string

            // Bounds checking, and avoid changing to the current page
            if ( image_index < 0 ) {
                image_index = 0;
            }
            if ( image_index > public.images.length-1 ) {
                image_index = public.images.length-1;
            }
            if ( image_index == private.current_image ) {
                return false;
            }
            
            // Start deleting the previous picture while we get the next ready
            $('#gallery #image img').animate({opacity: 0.0}, private.fade_speed, 'linear', function() {
                jQuery(this).remove();
            });

            // Get the image containers so we can size things
            var image_div = $('#gallery #image');
            var image_container = $('#gallery #image-container');

            // Calculate the image height by clamping it at the container height
            var image = public.images[image_index];
            var height = image.height > image_div.innerHeight() ? image_div.innerHeight() : image.height;

            // If the image is going to be resized, we need to recalculate its width to center it
            var resize_prc = private.max_height / image.height;
            var width = resize_prc < 1 ? ( image.width * resize_prc ) : image.width;

            // Append new picture and fade it in
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
                .animate({opacity: 1.0}, private.fade_speed, 'linear');

            // The image information (title, description, etc.)
            $('#gallery #image-info #image-title').html(image.title);  // TODO: Needs HTML escaping?
            $('#gallery #image-info #image-description').html(image.description);  // TODO: Needs HTML escaping?
            $('#gallery #image-info #image-keywords').html(image.keywords);  // TODO: Needs HTML escaping?

            // Set a hash tag so we could potentially bookmark this image
            window.location.hash = image.id; // TODO: URI encode?

            // Set the current image if we've come this far
             private.current_image = image_index;

            // Show and hide relevant controls
            this.updateImageNavigationControls();
            
            // Change the page if necessary
            this.pageToCurrent();

            // Highlight the current image in the navigation
            this.highlightNavigation();

            // Preload previous/next images
            if ( image_index > 0 ) { this.preload( image_index-1 ); }
            if ( image_index < (this.images.length-1) ) { this.preload( image_index+1 ); }

            return this;
        },

        highlightNavigation: function() {
            // Remove any current highlighting
            $('#gallery #navigation .navigation-block a').removeClass('active');
            
            // If the current image is on the current page, then find the 
            // block for that image and set it to active
            
            $('#gallery #navigation .navigation-block a[imgid=' + private.current_image + ']').addClass('active');
        },
        
        pageToCurrent: function() {
            return this.activatePage( parseInt(private.current_image / public.thumbnails_per_page) );
        },
        
        currentImageOnPage: function() {
            return this.imageOnPage(private.current_image, private.current_page);
        },
        
        imageOnPage: function( image_index, page ) {
            return page == parseInt(image_index / public.thumbnails_per_page);
        },

        oppositeDir: function(dir) {
            if ( dir == 'left' )
                return 'right';
            if ( dir == 'right' )
                return 'left';
            return '';
        },

        // Create a hidden image DOM object that self-destructs on load or error
        preload: function(image_index) {
            var image = public.images[image_index];
            if ( typeof(image) == 'undefined' || image.preloaded ) {
                return;
            }
        
            jQuery('<img />')
                .hide()
                .attr('src', image.url)
                .appendTo(document.body)
                .load(function () { image.preloaded = true; jQuery(this).remove(); })
                .error(function () { jQuery(this).remove(); });
        },
        
        // Change the navigation menu to a specific page
        activatePage: function( new_page ) {

            // Clamp left/right
            if ( new_page < 0 ) { new_page = 0; }
            if ( new_page > public.max_page ) { new_page = public.max_page; }
            if ( private.current_page == new_page ) { return false; }

            var dir = new_page > private.current_page ? 'left' : 'right';


            var old_page_block = $('#gallery #navigation-blocks div.page.active');

            // Create a new page and fill in the thumbnails

            var image_index = new_page * this.thumbnails_per_page;
            
            var page_block = $('<div />')
                .css({
                    opacity: 0.0
                })
                .addClass('page')
                .addClass('active');

            for ( var x=0; x<this.thumbnails_per_page; x++ ) {

                var image = this.images[image_index];

                if ( typeof(image) != 'undefined' ) {
                    var block = $('<div />')
                        .addClass('navigation-block');
                    
                    var link = $('<a />')
                        .attr('href', '#')
                        .attr('imgid', image_index)
                        .bind('click', GalCat.thumbnailClick)
                        .appendTo(block);

                    var img = $('<img />')
                        .attr('src', image.thumbnail)
                        .appendTo(link);
                    
                    block.appendTo(page_block);
                
                    image_index++;
                }

            }
            
            if ( dir == 'left' ) {
                page_block.appendTo('#navigation-blocks');
            }
            else {
                page_block.prependTo('#navigation-blocks');
            }
            
            // Clear the existing navigation
            
            old_page_block
                .find('a').attr('imgid', -1);

            old_page_block
                .removeClass('active')
                .addClass('fading')
                .animate({opacity: 0.0}, private.fade_speed, 'linear', function() {
                    jQuery(this).remove();
                });

            page_block.animate({opacity: 1.0}, private.fade_speed, 'linear');
            
            // New page is active
            
            private.current_page = new_page;

            // Hide controls at left/right bounds
            this.updatePageNavigationControls();

            return this;
        },
        
        updateImageNavigationControls: function() {
            if ( private.current_image <= 0 ) {
                $('#gallery #previous-image a').hide();
            }
            else {
                $('#gallery #previous-image a').show();
            }

            if ( private.current_image >= (public.images.length-1) ) {
                $('#gallery #next-image a').hide();
            }
            else {
                $('#gallery #next-image a').show();
            }
        },
        
        updatePageNavigationControls: function() {
            if ( private.current_page == 0 ) {
                $('#gallery #navigation #first-page a').hide();
                $('#gallery #navigation #previous-page a').hide();
            }
            else {
                $('#gallery #navigation #first-page a').show();
                $('#gallery #navigation #previous-page a').show();
            }

            if ( private.current_page == public.max_page ) {
                $('#gallery #navigation #next-page a').hide();
                $('#gallery #navigation #last-page a').hide();
            }
            else {
                $('#gallery #navigation #next-page a').show();
                $('#gallery #navigation #last-page a').show();
            }
        },
        
        prevImage: function() {
            public.activateImage( private.current_image - 1 );
        },
        nextImage: function() {
            public.activateImage( private.current_image + 1 );
        },
        prevPage: function() {
            public.activatePage( private.current_page - 1 );
        },
        nextPage: function() {
            public.activatePage( private.current_page + 1 );
        },
    

        //
        // JQUERY BINDING FUNCTIONS
        // 
        
        // jQuery event, clicked on a thumbnail
        thumbnailClick: function(e) {
            var image_index = $(this).attr('imgid');
            if ( private.current_image != image_index ) {
                public.activateImage( image_index );
            }
            return false;
        },

        prevImageClick: function(e) {
            public.prevImage();
            return false;
        },
        nextImageClick: function(e) {
            public.nextImage();
            return false;
        },

        firstPageClick: function(e) {
            public.activatePage(0);
            return false;
        },
        prevPageClick: function(e) {
            public.prevPage();
            return false;
        },
        nextPageClick: function(e) {
            public.nextPage();
            return false;
        },
        lastPageClick: function(e) {
            public.activatePage(public.max_page);
            return false;
        },
        
        keyDown: function(e) {
            if ( private.text_focus ) {
                return true;
            }
            if (e.keyCode === 37) {
                public.prevImage();
            }
            else if (e.keyCode === 39) {
                public.nextImage();
            }
        },
        
        textFocusIn: function() {
            private.text_focus = true;
        },
        textFocusOut: function() {
            private.text_focus = false;
        },

        
    };
    
    return public;
}();

$(document).ready( function() {
    $('#gallery #navigation .navigation-block a').bind('click', GalCat.thumbnailClick);
    $('#gallery #previous-image a').bind('click', GalCat.prevImageClick);
    $('#gallery #next-image a').bind('click', GalCat.nextImageClick);
    $('#gallery #first-page a').bind('click', GalCat.firstPageClick);
    $('#gallery #previous-page a').bind('click', GalCat.prevPageClick);
    $('#gallery #next-page a').bind('click', GalCat.nextPageClick);
    $('#gallery #last-page a').bind('click', GalCat.lastPageClick);
    $(document).bind('keydown', GalCat.keyDown);  
    $('#gallery #keyword-search').bind('focusin', GalCat.textFocusIn).bind('focusout', GalCat.textFocusOut);

    GalCat.updateImageNavigationControls();
    GalCat.updatePageNavigationControls();
    GalCat.preload( GalCat.current_image + 1 );
});
