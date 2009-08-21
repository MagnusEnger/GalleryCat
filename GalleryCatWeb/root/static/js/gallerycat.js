var GalCat = function() {
    var private = {
        current_image: 0,
        current_page: 0,
    };
    
    var public = {
        max_height: 400, 
        fade_speed: 500,
        images: [],
        thumbnails: [],

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

            // Start deleting the previous picture while we get the next ready
            $('#gallery #image img').animate({opacity: 0.0}, private.fade_speed, 'linear', function() {
                jQuery(this).remove();
            });

            // Get image info
            var image_div = $('#gallery #image');
            var image_container = $('#gallery #image-container');

            var image = public.images[image_id];
            var height = image.height > image_div.innerHeight() ? image_div.innerHeight() : image.height;

            // If the image is going to be resized, we need to recalculate its width
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

            // change info section
            $('#gallery #info #image-title').html(image.title);  // TODO: Title needs HTML escaping?


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

            // Highlight the current image in the navigation
            this.highlightNavigation();

            // Preload some images
            // 
            if ( image_id > 0 ) { this.preload( image_id-1 ); }
            if ( image_id < (this.images.length-1) ) { this.preload( image_id+1 ); }

            return this;
        },

        highlightNavigation: function() {
            // Remove any current highlighting
            $('#gallery #navigation .navigation-block a').removeClass('active');
            
            // Find the current image in the navigation page
            $('#gallery #navigation .navigation-block a[imgid=' + private.current_image + ']').addClass('active');
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
        changePage: function( add ) {
            var previous_page = private.current_page;
            private.current_page += add;
            if ( private.current_page < 0 ) { private.current_page = 0; }
            if ( private.current_page > public.max_page ) { private.current_page = public.max_page; }
            if ( private.current_page == previous_page ) { return false; }
            
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

            // Set all the images in the thumbnails.  This would be way nicer by creating a new page
            // and sliding it in...

            var image_id = private.current_page*this.thumbnails_per_page;
            for ( var x=0; x<this.thumbnails_per_page; x++ ) {
                var link = $('#gallery #navigation #nav-' + x + ' a');
                var img = link.find('img');

                if ( image_id >= this.images.length ) {
                    link.attr('imgid', -1).hide();
                }
                else {
                    img.attr('src', this.images[image_id].thumbnail)
                    link.attr('imgid', image_id).show();
                }
                image_id++;
            }

            return this;
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
            public.activateImage( private.current_image - 1 );
            return false;
        },
        nextImageClick: function(e) {
            public.activateImage( private.current_image + 1 );
            return false;
        },

        firstPageClick: function(e) {
            public.changePage(-public.max_page);
            return false;
        },
        prevPageClick: function(e) {
            public.changePage(-1);
            return false;
        },
        nextPageClick: function(e) {
            public.changePage(1);
            return false;
        },
        lastPageClick: function(e) {
            public.changePage(public.max_page);
            return false;
        },
        
        keyPressed: function(e) {
              if (e.keyCode === 37) {
                  public.activateImage( private.current_image - 1 );
              }
              else if (e.keyCode === 39) {
                  public.activateImage( private.current_image + 1 );
              }
        }

        
    };
    
    return public;
}();





 


