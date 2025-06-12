import $ from "jquery";
window.$ = $;
window.jQuery = $;

import Rails from "@rails/ujs";
Rails.start();
window.Rails = Rails;

import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

import '../channels'
import '@nathanvda/cocoon';

import "../packs/answers";
import "../packs/questions";
import "../packs/flash";
import "../packs/gist";
import "../packs/votes";
// import "../packs/comment_submit"
