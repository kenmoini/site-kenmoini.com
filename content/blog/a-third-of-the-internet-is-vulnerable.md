---
title: "A Third of the Internet Is Vulnerable"
date: 2019-01-04T20:38:59-05:00
draft: false
tags: 
  - WordPress
  - jQuery
  - jQuery UI
  - JavaScript
  - security
  - vulnerability
---

So I didn't want to end up working on something all night long today, it's Friday after all.
What I decided to do is clean up, test, and release some code I have running on my favorite guenea pig - [my work's website](https://fiercesw.com/).

### Project: Multiple WordPress installations
#### Task: Fix vulnerabilities found in the version of jQuery and jQuery UI that are shipped with WordPress

[Lighthouse](https://developers.google.com/web/tools/lighthouse/) is a cool tool I use in web development, helps test and hone in on best practices, performance improvements, SEO, PWA, and more.  It also features a nice high-level Security set of tests.

I scanned a few sites the other day with Lighthouse and was very surprised to find vulnerable versions of [jQuery](https://snyk.io/vuln/npm:jquery?lh=1.12.4) and [jQuery UI](https://snyk.io/vuln/npm:jquery-ui?lh=1.11.4).

{{< figure src="/images/content-stuff/vulnerable-jquery.jpg" link="/content-stuff/vulnerable-jquery.jpg" class="text-center" >}}

At first I did what anyone would do: check for updates.  Nope, all checks out Charlie.
Then I figured it might have been a 3rd party script or plugin that was including these old & vulnerable jQuery packages.  Nope, no specific jQuery scripts/versions are enqueued.  Weird, let's check the source and the path of the set of files in question...wait, is that the copy of jQuery included in WordPress core?  Wtfhax?

### Trust Thy Neighbor - but never your platform
Ok, fuck that I'm not running vulnerable code no matter who supplies it.  Don't they know about this issue though?  The answer, unsurprisingly, is yes though what is surprising is that [there has been discussion for a while](https://core.trac.wordpress.org/ticket/37110) and other cases of it being brought up earlier as well.

Initially it looks like the WordPress developers are looking out for the slurry of shit that's out their in their plugin pool - all the poorly developed plugins that are probably vulnerable in other ways in and of their own right.  These poor plugins rely on the version of jQuery provided by WordPress, what about those poor bastards?!  Oh, and updating would break IE6/7/8 compatability!  Think of all the already vulnerable sites out there, they couldn't push a change to update security at the risk of breaking compatability!  _**Inconceivable!**_

Well, thankfully I don't run poorly crafted plugins, and few plugins even at that.  I'm sure they're all properly using jQuery, and my front-end uses newer versions as well since it's based on Bootstrap 4!
We can easily rip out the old scripts and replace with newer ones thanks to some built-in functions.

**Testing on the front-end** - flawless.
**Testing in the WordPress control panel?** - Bugs and errors!  Yay!

So, here's another funny thing - evidently some of the _WordPress Core Codebase_ isn't properly using jQuery and needs to be refactored to use newer versions that aren't vulnerable - and there lies the rub.

### Hack and slash
So here's a bit of a round-about way to update the versions of jQuery and jQuery UI that are served on your front-end of a WordPress installation (tested with the latest 5.0.2 release as of this writing, so new shit).

What we'll do is _deregister_ the built-in WordPress jQuery scripts, and override with newly queued files that we provide ourselves.  This can easily be made into a plug-in, but for ease of use and maintenance I've placed it in our theme's _function.php_ file.

Something to note is that we're only going to do this if the page loaded is not a WP Admin page or the WP Customizer because that code base still needs refactoring to work.  Thankfully the largest attack surface is the front-end (this contact forms, etc), and the Admin/Customizer has additional authentication measures in place before an attacker could hit an older version of jQuery.

{{< highlight php >}}
<?php
function kemo_jquery_updater() {
  wp_deregister_script('jquery');
  wp_deregister_script('jquery-core');
  wp_deregister_script('jquery-migrate');


  wp_deregister_script('jquery-ui-core');
  wp_deregister_script('jquery-ui-widget');
  wp_deregister_script('jquery-ui-accordion');
  wp_deregister_script('jquery-ui-autocomplete');
  wp_deregister_script('jquery-ui-button');
  wp_deregister_script('jquery-ui-datepicker');
  wp_deregister_script('jquery-ui-dialog');
  wp_deregister_script('jquery-ui-draggable');
  wp_deregister_script('jquery-ui-droppable');
  wp_deregister_script('jquery-ui-menu');
  wp_deregister_script('jquery-ui-mouse');
  wp_deregister_script('jquery-ui-position');
  wp_deregister_script('jquery-ui-progressbar');
  wp_deregister_script('jquery-ui-selectable');
  wp_deregister_script('jquery-ui-resizable');
  wp_deregister_script('jquery-ui-selectmenu');
  wp_deregister_script('jquery-ui-sortable');
  wp_deregister_script('jquery-ui-slider');
  wp_deregister_script('jquery-ui-spinner');
  wp_deregister_script('jquery-ui-tooltip');
  wp_deregister_script('jquery-ui-tabs');
  wp_deregister_script('jquery-ui-effects-core');
  wp_deregister_script('jquery-ui-effects-blind');
  wp_deregister_script('jquery-ui-effects-bounce');
  wp_deregister_script('jquery-ui-effects-clip');
  wp_deregister_script('jquery-ui-effects-drop');
  wp_deregister_script('jquery-ui-effects-explode');
  wp_deregister_script('jquery-ui-effects-fade');
  wp_deregister_script('jquery-ui-effects-fold');
  wp_deregister_script('jquery-ui-effects-highlight');
  wp_deregister_script('jquery-ui-effects-pulsate');
  wp_deregister_script('jquery-ui-effects-scale');
  wp_deregister_script('jquery-ui-effects-shake');
  wp_deregister_script('jquery-ui-effects-slide');
  wp_deregister_script('jquery-ui-effects-transfer');


  wp_register_script( 'jquery', get_stylesheet_directory_uri() . '/js/jquery-3.3.1.min.js', array(), '3.3.1' );
  wp_register_script( 'jquery-core', get_stylesheet_directory_uri() . '/js/jquery-3.3.1.min.js', array(), '3.3.1' );
  wp_register_script( 'jquery-migrate', get_stylesheet_directory_uri() . '/js/jquery-migrate-3.0.1.min.js', array('jquery'), '3.0.1' );


  wp_register_script( 'jquery-ui-core', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/jquery-ui-core.min.js', array('jquery-migrate'), '1.12.1' );
  wp_register_script( 'jquery-ui-widget', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/widget.min.js', array('jquery-ui-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-accordion', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/accordion.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-autocomplete', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/autocomplete.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-button', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/button.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-datepicker', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/datepicker.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-dialog', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/dialog.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-draggable', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/draggable.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-droppable', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/droppable.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-menu', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/menu.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-mouse', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/mouse.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-position', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/position.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-progressbar', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/progressbar.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-selectable', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/selectable.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-resizable', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/resizable.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-selectmenu', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/selectmenu.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-sortable', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/sortable.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-slider', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/slider.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-spinner', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/spinner.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-tooltip', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/tooltip.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-tabs', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/tabs.min.js', array('jquery-ui-widget'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-core', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect.min.js', array('jquery-ui-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-blind', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-blind.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-bounce', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-bounce.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-clip', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-clip.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-drop', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-drop.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-explode', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-explode.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-fade', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-fade.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-fold', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-fold.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-highlight', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-highlight.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-pulsate', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-pulsate.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-scale', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-scale.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-shake', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-shake.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-slide', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-slide.min.js', array('jquery-effects-core'), '1.12.1' );
  wp_register_script( 'jquery-ui-effects-transfer', get_stylesheet_directory_uri() . '/js/vendor/jquery-ui/effect-transfer.min.js', array('jquery-effects-core'), '1.12.1' );

}
$wp_admin = is_admin();
$wp_customizer = is_customize_preview();

if ( $wp_admin || $wp_customizer ) {
  // echo 'We are in the WP Admin or in the WP Customizer';
}
else {
  add_action('wp_enqueue_scripts', 'kemo_jquery_updater');
}
{{< / highlight >}}

Pretty simple script, just a lot of repeated functions.

### Sourcing the Scripts
Ok, that's how we update the enqueued scripts, but where do you get the scripts from?

jQuery is easy, just grab the latest minified version of jQuery and jQuery Migrate off [their site](https://jquery.com/download/).

jQuery UI however, is a bit more laborous.  You see, they only release a concatenated and minified version of jQuery UI now and WordPress uses separate files for each jQuery UI module.  No bueno, not as easy as we'd like but still not too hard.

### Git With It
Weird thing with jQuery UI - it's not really actively developed any more but there are still a number of changes that are reflected in the **master** branch of their codebase so you have to be careful not to get this because it's more bleeding edge.

Navigate over to the repo, use the Branch/Tag switcher to select the 1.12.1 tag (last stable, hopefully good release)...or just [click this link](https://github.com/jquery/jquery-ui/tree/1.12.1).

Clone it, or just download a copy.

There isn't anything to really build...it even uses an old version of Bower that gives you some nice warnings when creating the development environment.  The only thing that does is allow you to run tests which we don't care about (hint: they all pass!)

Make a copy of **/ui/** folder, and this is where the uncompressed/minified scripts and individual modules live.  We'll need to concatenate some of the jQuery UI core files into a single file.  Next, create a new copy of all the JS files with a _.min.js_
{{< highlight bash >}}
$ cp -r ui/ ui-min/
$ cd ui-min/
$ cat data.js disable-selection.js focusable.js form.js ie.js jquery-1-7.js keycode.js labels.js plugin.js safe-active-element.js safe-blur.js scroll-parent.js tabbable.js unique-id.js version.js >> jquery-ui-core.js
$ find . -name '*.js' | while read oldname; do mv "$oldname" "${oldname/.js/.min.js}"; done
$ rm -rf ./i18n
{{< / highlight >}}
Oh, also get rid of that international shit, WordPress doesn't use it anyway (that I know of).  Just takes more time to process.

Now before we minify, we need to add some backported bits to add support for the $.ui function binding.  Open the **jquery-ui-core.min.js** file that was created earlier, and replace line 25 (should look like this...
{{< highlight js >}}
} ( function( $ ) {
{{< / highlight >}}
...with this...
{{< highlight js >}}
} ( function( $ ) { $.ui = $.ui || {};
{{< / highlight >}}

Now, we get to minify all the things.  You'll need Node.js for this, but sadly that's everywhere and/or easy to get so I'll assume you know how to do as much and are ready to run...
{{< highlight bash >}}
$ cd ..
$ npm install -g minify-all
$ minify-all ui-min/
{{< / highlight >}}

Now we're playing the waiting game while it crunches the scripts, but after that we can upload that to our site in the appropriate places, make sure the script matches the paths, and bingo bango, you got yourself a more secure WordPress site!
