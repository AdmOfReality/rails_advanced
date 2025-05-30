import consumer from "./consumer"

consumer.subscriptions.create("QuestionsChannel", {
  connected() {
    console.log("Connected to QuestionS channel(list)");
  },

  received(data) {
    $('.questions').append(data);
  }
});
