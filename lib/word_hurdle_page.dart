import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:word_hurdle_puzzle/helper_functions.dart';
import 'package:word_hurdle_puzzle/hurdle_provider.dart';
import 'package:word_hurdle_puzzle/wordle_view.dart';

import 'keyboard_view.dart';

class WordHurdlePage extends StatefulWidget {
  const WordHurdlePage({super.key});

  @override
  State<WordHurdlePage> createState() => _WordHurdlePageState();
}

class _WordHurdlePageState extends State<WordHurdlePage> {
  @override
  void didChangeDependencies() {
    Provider.of<HurdleProvider>(context, listen: false).init();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Hurdle'),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.80,
                child: Consumer<HurdleProvider>(
                  builder: (context, provider, child) =>
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 4,
                            crossAxisSpacing: 4),
                        itemCount: provider.hurdleBoard.length,
                        itemBuilder: (context, index) {
                          final wordle = provider.hurdleBoard[index];
                          return WordleView(
                            wordle: wordle,
                          );
                        },
                      ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<HurdleProvider>(
                builder: (context, provider, child) =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            provider.deleteLetter();
                          },
                          child: const Text('DELETE'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                         _handleInput(provider);

                          },
                          child: const Text('SUBMIT'),
                        ),
                      ],
                    ),
              ),
            ),
            SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Consumer<HurdleProvider>(
                builder: (context, provider, child) =>
                    KeyboardView(
                      excludedLetters: provider.excludedLetters,
                      onPressed: (value) {
                        provider.inputLetter(value);
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  _handleInput(HurdleProvider provider){
    if (!provider.isValidWord) {
      showMsg(context,
          'Not a valid word in my dictionary!');
      return;
    }
    if (provider.shouldCheckForAnswer) {
      provider.checkAnswer();
    }
    if (provider.wins) {
      final player= AudioPlayer();
      player.play(AssetSource('theme.wav'));
      showResult(context: context,
          title: 'You Win!!!',
          body: 'The word was ${provider.targetWord}',
          onPlayAgain: () {
            Navigator.pop(context);
            provider.reset();
          },
          onCancel: () {
            Navigator.pop(context);
          });
    } else if (provider.noAttemptsLeft) {
      showResult(context: context,
          title: 'You Lost!!!',
          body: 'The word was ${provider.targetWord}',
          onPlayAgain: (){
            Navigator.pop(context);
            provider.reset();
          },
          onCancel: (){
            Navigator.pop(context);

          });
    }
  }
}
