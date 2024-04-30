import 'package:metal/gen/assets.gen.dart';

class GameModel {
  final String title;
  final String emojiPart;
  final String about;
  final String rule;

  GameModel(
      {required this.title,
      required this.emojiPart,
      required this.about,
      required this.rule});
}

List<GameModel> gameData = [
  GameModel(
      title: "Two Truths and A lie",
      emojiPart:  Assets.images.chatSmilingFaceEmoji1.path,
      about:
          "Two Truths and a Lie is a fun and easy icebreaker game that's perfect for getting to know a new person. The objective of the game is to correctly identify which statement is the false one.",
      rule:
          "Explain the Rules: Each player will share three statements about themselves, two of which are true and one is false. The other player must try to guess which statement is false. Select a player to go first: Discuss and agree on the player to go first. The first person to play will write three statements about themselves, and the other player will guess which statement is the lie. Respond: After the first player has written their statements, the other player must guess which statement they think is false. The first player will reveal which statement was the lie. The game then moves on to the other player, who will make their own three statements, and so on. The game continues by rotating turns Score: Record the scores in your chat to track the winner. Update the scores as you complete new rounds. You can keep score by awarding points to players who correctly guess the lie."),
  GameModel(
      title: "Never Have I Ever",
      emojiPart: Assets.images.chatAstonishedFaceEmoji1.path,
      about:
          "Never Have I Ever is a classic icebreaker game that involves each player taking turns making a statement about something they have never done, and the other player responding if they have done that thing.",
      rule:
          "Explain the Rules: Each player will write a statement starting with Never have I ever... and then completing the statement with something they have never done. The other player will respond if they have done that thing or not. Select a player to go first: Discuss and agree on the player to go first. This person will write a statement starting with Never have I ever... Respond: After the first player has written their statement, the other player will type No if they have never done that thing or Yes if they have done it. The game then moves on to the next player, who will make their own Never have I ever statement, and so on. Keep the game going for as long as you'd like, or until you run out of ideas. You can mix up the rules by adding a twist, such as making each of you who have done the thing tell the story of their experience, or having players who have never done the thing explain why they haven’t."),
 
  GameModel(
      title: "Name A Thing",
      emojiPart:     Assets.images.chatEmojiWomanRaisingHand1.path,
      about:
          "Name a Thing is a simple and fun game that can reveal some interesting and surprising things about the people you're playing with. It's an easy and fun icebreaker game",
      rule:
          "Explain the rules: Explain to the other player that each player will take turns choosing a category which the two of you will try to name things within that category. Choose a category: Select a category, such as types of fruit, “movies”, “songs”, ”famous actors”, “Persons starting with A”, Countries”, universities, streets, etc. Choose the first player: Discuss and agree on the player to go first. Set a timer: Set a timer for 10 seconds to 30 seconds, depending on the difficulty of the category. The players take turns in keeping time and calling out the names. Start the game: The first player starts the game by naming something that fits into the chosen category. For example, if the category is ”types of fruit”, they might say ”apple”. Pass the turn: The game then moves on to the next player, who must name something that fits into the category, such as ”banana”. Then it goes back to the first player until a player is unable to name a thing or inaccurately names a thing in the chosen category then the last player that named rightly wins the round. Change the category: You can mix up the game by changing the category after each round or choosing a new category every few turns. Score: Record the scores in your chat to track the winner. Update the scores as you complete new rounds."),
  GameModel(
      title: "Truth and Dare",
      emojiPart:Assets.images.chatPersonSayingMoreEmoji1.path,
      about:
          "Truth or Dare is a fun and entertaining icebreaker game that can reveal some interesting and hilarious truths and dares, and can break down barriers and make people feel more comfortable around each other.",
      rule:
          "Explain the rules: Explain to the other player that each player will take turns choosing between answering a truth question or completing a dare. Choose the first player: Discuss and agree on the player to go first. This person will choose whether they want to answer a truth question or complete a dare by typing Truth or Dare in the chat. Truth: If the player chooses truth, they will be asked a question that they must answer truthfully. The other player can take turn to ask the question. Questions do not include bio data of participants such as name, address, age, city lived and etc. Any questions that can unveil is metal is prohibited and violates the rules of this application. This can lead to your game function being suspended. Dare: If the player chooses dare, they will be given a task that they must complete. The other player can come up with the dares. For example guess write a poem about me. Complete the task: If the player chooses dare, they must complete the task assigned to them. If they refuse, they will be penalized with a punishment that can be agreed upon before the game starts. Rotate turns: The game then moves on to the second player, who will choose whether they want to answer a truth question or complete a dare. Keep it going: Keep the game going for as long as you'd like, or until you run out of ideas.")
];
