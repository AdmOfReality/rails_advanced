import $ from "jquery";
window.$ = $;
window.jQuery = $;

import Rails from "@rails/ujs";
Rails.start();
window.Rails = Rails;

import * as ActiveStorage from "@rails/activestorage";
ActiveStorage.start();

import "../packs/answers"
import "../packs/flash"
import "../packs/questions"
