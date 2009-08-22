var GalCat = function() {
    var private = {
        current_image: 0,
        current_page: 0,
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

        activateImage: function( image_id ) {

            image_id = parseInt(image_id);  // Fixes odd issue where image_id is sometimes treated as a string

            // Bounds checking, and avoid changing to the current page
            if ( image_id < 0 ) {
                image_id = 0;
            }
            if ( image_id > public.images.length-1 ) {
                image_id = public.images.length-1;
            }
            if ( image_id == private.current_image ) {
                return false;
            }
            
            // What direction are we going?  In case we need to change pages
            var direction = image_id < private.current_image ? 'l' : 'r';

            // Start deleting the previous picture while we get the next ready
            $('#gallery #image img').animate({opacity: 0.0}, private.fade_speed, 'linear', function() {
                jQuery(this).remove();
            });

            // Get the image containers so we can size things
            var image_div = $('#gallery #image');
            var image_container = $('#gallery #image-container');

            // Calculate the image height by clamping it at the container height
            var image = public.images[image_id];
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
            $('#gallery #info #image-title').html(image.title);  // TODO: Title needs HTML escaping?

            // Set the current image if we've come this far
             private.current_image = image_id;


            // Show and hide relevant controls
            if ( image_id <= 0 ) {
                $('#gallery #previous-image a').hide();
            }
            else {
                $('#gallery #previous-image a').show();
            }

            if ( image_id >= (public.images.length-1) ) {
                $('#gallery #next-image a').hide();
            }
            else {
                $('#gallery #next-image a').show();
            }

            // Change the page if necessary
            if ( !this.currentImageOnPage ) {
                
            }

            // Highlight the current image in the navigation
            this.highlightNavigation();

            // Preload previous/next images
            if ( image_id > 0 ) { this.preload( image_id-1 ); }
            if ( image_id < (this.images.length-1) ) { this.preload( image_id+1 ); }

            return this;
        },

        highlightNavigation: function() {
            // Remove any current highlighting
            $('#gallery #navigation .navigation-block a').removeClass('active');
            
            // If the current image is on the current page, then find the 
            // block for that image and set it to active
            
            $('#gallery #navigation .navigation-block a[imgid=' + private.current_image + ']').addClass('active');
        },
        
        currentImageOnPage: function() {
            return this.imageOnPage(private.current_image, private.current_page);
        },
        
        imageOnPage: function( image_id, page ) {
            return    image_id >= ( page     * public.thumbnails_per_page )
                   && image_id <  ( (page+1) * public.thumbnails_per_page );
        },

        oppositeDir: function(dir) {
            if ( dir == 'left' )
                return 'right';
            if ( dir == 'right' )
                return 'left';
            return '';
        },

        // Create a hidden image DOM object that self-destructs on load or error
        preload: function(image_id) {
            var image = public.images[image_id];
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

            if ( new_page < 0 ) { new_page = 0; }
            if ( new_page > public.max_page ) { new_page = public.max_page; }
            if ( private.current_page == new_page ) { return false; }

            var dir = new_page > private.current_page ? 'left' : 'right';

            
            var old_page_block = $('#navigation-blocks div.page.active');

            // Create a new page and fill in the thumbnails

            var image_id = new_page * this.thumbnails_per_page;
            
            var page_block = $('<div />')
                .css({
                    opacity: 0.0
                })
                .addClass('page')
                .addClass('active');

            for ( var x=0; x<this.thumbnails_per_page; x++ ) {

                var image = this.images[image_id];

                if ( typeof(image) != 'undefined' ) {
                    var block = $('<div />')
                        .addClass('navigation-block');
                    
                    var link = $('<a />')
                        .attr('href', '#')
                        .attr('imgid', image_id)
                        .bind('click', GalCat.thumbnailClick)
                        .appendTo(block);
                
                    var img = $('<img />')
                        .attr('src', image.thumbnail)
                        .appendTo(link);
                    
                    block.appendTo(page_block);
                
                    image_id++;
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
                .animate({opacity: 0.0}, private.fade_speed, 'linear', function() {
                    jQuery(this).remove();
                });

            page_block.animate({opacity: 1.0}, private.fade_speed, 'linear');
            
            private.current_page = new_page;

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

            return this;
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
            var image_id = $(this).attr('imgid');
            if ( private.current_image != image_id ) {
                public.activateImage( image_id );
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
        
        keyPressed: function(e) {
              if (e.keyCode === 37) {
                  public.prevImage();
              }
              else if (e.keyCode === 39) {
                  public.nextImage();
              }
        }

        
    };
    
    return public;
}();





 


