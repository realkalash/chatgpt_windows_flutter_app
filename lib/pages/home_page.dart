import 'dart:io';

import 'package:fluent_gpt/common/conversaton_style_enum.dart';
import 'package:fluent_gpt/common/prefs/app_cache.dart';
import 'package:fluent_gpt/dialogs/chat_room_dialog.dart';
import 'package:fluent_gpt/dialogs/cost_dialog.dart';
import 'package:fluent_gpt/dialogs/edit_conv_length_dialog.dart';
import 'package:fluent_gpt/main.dart';
import 'package:fluent_gpt/utils.dart';
import 'package:fluent_gpt/widgets/confirmation_dialog.dart';
import 'package:fluent_gpt/widgets/drop_region.dart';
import 'package:fluent_gpt/widgets/markdown_builders/markdown_utils.dart';
import 'package:fluent_gpt/widgets/message_list_tile.dart';
import 'package:fluent_gpt/shell_driver.dart';
import 'package:fluent_gpt/system_messages.dart';
import 'package:fluent_gpt/widgets/input_field.dart';
import 'package:fluent_gpt/widgets/selectable_color_container.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as ic;
import 'package:widget_and_text_animator/widget_and_text_animator.dart';

import '../providers/chat_gpt_provider.dart';

final promptTextFocusNode = FocusNode();

class ChatRoomPage extends StatelessWidget {
  const ChatRoomPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ScaffoldPage(
      header: PageHeader(title: PageHeaderText()),
      content: Stack(
        fit: StackFit.expand,
        children: [
          ChatGPTContent(),
          HomeDropOverlay(),
          HomeDropRegion(),
        ],
      ),
    );
  }
}

// isDropOverlayVisible is a BehaviorSubject that is used to show the overlay when a drag is over the drop region.
final BehaviorSubject<bool> isDropOverlayVisible =
    BehaviorSubject<bool>.seeded(false);

class HomeDropOverlay extends StatelessWidget {
  const HomeDropOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isDropOverlayVisible,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: FluentTheme.of(context).accentColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Center(
                  child: Icon(
                    FluentIcons.file_image,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ConversationStyleRow extends StatelessWidget {
  const ConversationStyleRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Expander(
      contentPadding: EdgeInsets.zero,
      header: const Text(
        'Conversation style',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      content: StreamBuilder(
        stream: conversationLenghtStyleStream,
        builder: (_, __) => StreamBuilder<Object>(
            stream: conversationStyleStream,
            builder: (context, snapshot) {
              final lenghtStyle = conversationLenghtStyleStream.value;
              final style = conversationStyleStream.value;
              return Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ConversationStyleEnum.values
                          .map((e) => SelectableColorContainer(
                                selectedColor:
                                    FluentTheme.of(context).accentColor,
                                unselectedColor: FluentTheme.of(context)
                                    .accentColor
                                    .withOpacity(0.5),
                                isSelected: style == e,
                                onTap: () => conversationStyleStream.add(e),
                                child: Text(e.name,
                                    style: const TextStyle(fontSize: 12)),
                              ))
                          .toList(),
                    ),
                  ),
                  Text(
                    'Conversation length',
                    style: FluentTheme.of(context).typography.subtitle,
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ConversationLengthStyleEnum.values.map((e) {
                        return SelectableColorContainer(
                          selectedColor: FluentTheme.of(context).accentColor,
                          unselectedColor: FluentTheme.of(context)
                              .accentColor
                              .withOpacity(0.5),
                          isSelected: lenghtStyle == e,
                          onTap: () => conversationLenghtStyleStream.add(e),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(e.name,
                                  style: const TextStyle(fontSize: 12)),
                              SizedBox.square(
                                dimension: 16,
                                child: Button(
                                  style: ButtonStyle(
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.zero),
                                  ),
                                  onPressed: () =>
                                      editConversationStyle(context, e),
                                  child: const Icon(
                                      ic.FluentIcons.edit_20_regular),
                                ),
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  editConversationStyle(
      BuildContext context, ConversationLengthStyleEnum item) async {
    final ConversationLengthStyleEnum? newItem =
        await ConversationStyleDialog.show(context, item);
    if (newItem != null) {
      final indexOldItem = ConversationLengthStyleEnum.values.indexOf(item);
      ConversationLengthStyleEnum.values.remove(item);
      ConversationLengthStyleEnum.values.insert(indexOldItem, newItem);
      // to update the UI
      conversationLenghtStyleStream.add(conversationLenghtStyleStream.value);
    }
  }
}

class PageHeaderText extends StatelessWidget {
  const PageHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    var chatProvider = context.watch<ChatGPTProvider>();
    return Focus(
      canRequestFocus: false,
      descendantsAreTraversable: false,
      child: Column(
        children: [
          StreamBuilder(
            stream: selectedChatRoomIdStream,
            builder: (_, __) {
              return GestureDetector(
                onTap: () => EditChatRoomDialog.show(
                  context: context,
                  room: selectedChatRoom,
                  onOkPressed: () {},
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                        child: TextAnimator(
                      selectedChatRoom.chatRoomName,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    )),
                    if (selectedChatRoom.apiToken.isEmpty ||
                        selectedChatRoom.apiToken == 'empty')
                      Tooltip(
                        message: 'API token is empty!',
                        child: Icon(ic.FluentIcons.warning_24_filled,
                            color: Colors.red, size: 24),
                      ),
                  ],
                ),
              );
            },
          ),
          const ConversationStyleRow(),
          Row(
            children: [
              HyperlinkButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => showCostCalculatorDialog(context),
                child: Text(
                  ' Tokens: ${selectedChatRoom.tokens ?? 0} | ${(selectedChatRoom.costUSD ?? 0.0).toStringAsFixed(4)}\$',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const Spacer(),
              const IncludeConversationSwitcher(),
              if (chatProvider.selectionModeEnabled) ...[
                IconButton(
                  icon:
                      Icon(ic.FluentIcons.delete_16_filled, color: Colors.red),
                  onPressed: () {
                    chatProvider.deleteSelectedMessages();
                  },
                ),
                IconButton(
                  icon: const Icon(FluentIcons.cancel),
                  onPressed: () {
                    chatProvider.disableSelectionMode();
                  },
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  void showCostCalculatorDialog(BuildContext context) {
    final tokens = selectedChatRoom.tokens ?? 0;
    showDialog(
      context: context,
      builder: (context) => CostDialog(tokens: tokens),
    );
  }
}

class IncludeConversationSwitcher extends StatelessWidget {
  const IncludeConversationSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatGPTProvider chatProvider = context.watch<ChatGPTProvider>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FlyoutListTile(
          text: const Icon(FluentIcons.full_history),
          tooltip: 'Include conversation',
          trailing: Checkbox(
            checked: chatProvider.includeConversationGlobal,
            onChanged: (value) {
              chatProvider.setIncludeWholeConversation(value ?? false);
            },
          ),
        ),
        if (Platform.isWindows)
          FlyoutListTile(
            text: const Icon(FluentIcons.search_data),
            tooltip: 'Tool Search files',
            trailing: Checkbox(
              checked: AppCache.gptToolSearchEnabled.value!,
              onChanged: (value) {
                AppCache.gptToolSearchEnabled.value = value;
                // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                chatProvider.notifyListeners();
              },
            ),
          ),
        FlyoutListTile(
          text: const Icon(FluentIcons.python_language),
          tooltip: 'Tool Python code execution',
          trailing: Checkbox(
            checked: AppCache.gptToolPythonEnabled.value!,
            onChanged: (value) {
              AppCache.gptToolPythonEnabled.value = value;
              // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
              chatProvider.notifyListeners();
            },
          ),
        ),
      ],
    );
  }
}

class ChatGPTContent extends StatefulWidget {
  const ChatGPTContent({super.key});

  @override
  State<ChatGPTContent> createState() => _ChatGPTContentState();
}

class _ChatGPTContentState extends State<ChatGPTContent> {
  @override
  void initState() {
    super.initState();
    // promptTextFocusNode.requestFocus();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var chatProvider = context.read<ChatGPTProvider>();
      chatProvider.listItemsScrollController.animateTo(
        chatProvider.listItemsScrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  void toggleSelectAllMessages() {
    final allMessages = selectedChatRoom.messages;
    final chatProvider = context.read<ChatGPTProvider>();
    if (!chatProvider.selectionModeEnabled) {
      chatProvider.selectAllMessages(allMessages);
    } else {
      chatProvider.disableSelectionMode();
    }
  }

  Future<void> promptDeleteSelectedMessages() async {
    final chatProvider = context.read<ChatGPTProvider>();
    final result = await ConfirmationDialog.show(
      context: context,
      isDelete: true,
    );
    if (result) {
      chatProvider.deleteSelectedMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatProvider = context.watch<ChatGPTProvider>();
    chatProvider.context = context;

    return CallbackShortcuts(
      bindings: {
        if (Platform.isMacOS)
          const SingleActivator(LogicalKeyboardKey.keyA,
              meta: true, shift: true): toggleSelectAllMessages
        else
          const SingleActivator(LogicalKeyboardKey.keyA,
              control: true, shift: true): toggleSelectAllMessages,
        if (chatProvider.selectionModeEnabled)
          const SingleActivator(LogicalKeyboardKey.escape):
              chatProvider.disableSelectionMode,
        if (Platform.isMacOS)
          const SingleActivator(LogicalKeyboardKey.backspace, meta: true):
              promptDeleteSelectedMessages
        else
          const SingleActivator(LogicalKeyboardKey.delete, control: true):
              promptDeleteSelectedMessages,
      },
      child: GestureDetector(
        onTap: promptTextFocusNode.requestFocus,
        behavior: HitTestBehavior.translucent,
        excludeFromSemantics: true,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              children: <Widget>[
                Expanded(
                  child: StreamBuilder(
                      stream: chatRoomsStream,
                      builder: (context, snapshot) {
                        return ListView.builder(
                          controller: chatProvider.listItemsScrollController,
                          itemCount: messages.entries.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages.entries.elementAt(index).value;
                            final dateTimeRaw = messages.entries
                                .elementAt(index)
                                .value['created'];

                            return MessageCard(
                              key: ValueKey('message_$index'),
                              id: messages.entries.elementAt(index).key,
                              message: message,
                              dateTime: DateTime.tryParse(dateTimeRaw ?? ''),
                              selectionMode: chatProvider.selectionModeEnabled,
                              isError: message['error'] == 'true',
                              textSize: chatProvider.textSize,
                              isCompactMode: false,
                            );
                          },
                        );
                      }),
                ),
                const HotShurtcutsWidget(),
                const InputField()
              ],
            ),
            const Positioned(
              bottom: 128,
              right: 16,
              width: 32,
              height: 32,
              child: _ScrollToBottomButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollToBottomButton extends StatelessWidget {
  const _ScrollToBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatGPTProvider>();
    return ToggleButton(
      checked: provider.scrollToBottomOnAnswer,
      style: ToggleButtonThemeData(
        checkedButtonStyle: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
          backgroundColor: WidgetStateProperty.all(
              context.theme.accentColor.withOpacity(0.5)),
        ),
        uncheckedButtonStyle: ButtonStyle(
          padding: WidgetStateProperty.all(EdgeInsets.zero),
        ),
      ),
      onChanged: (value) {
        provider.toggleScrollToBottomOnAnswer();
        if (value) {
          provider.scrollToEnd();
        }
      },
      child: const Icon(FluentIcons.down, size: 16),
    );
  }
}

Future<void> displayCopiedToClipboard() {
  return displayInfoBar(
    appContext!,
    builder: (context, close) => InfoBar(
      title: const Text('Copied'),
      severity: InfoBarSeverity.info,
      style: InfoBarThemeData(icon: (_) => ic.FluentIcons.clipboard_24_filled),
    ),
  );
}

void chooseCodeBlockDialog(BuildContext context, List<String> blocks) {
  showDialog(
    context: context,
    builder: (ctx) => ContentDialog(
      title: const Text('Choose code block'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final block in blocks) ...[
            ListTile(
              onPressed: () {},
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox.square(
                    dimension: 30,
                    child: ToggleButton(
                      onChanged: (_) {
                        Clipboard.setData(ClipboardData(text: block));
                        displayCopiedToClipboard();
                      },
                      checked: false,
                      child: const Icon(FluentIcons.copy, size: 10),
                    ),
                  ),
                ],
              ),
              subtitle: buildMarkdown(
                context,
                '```python\n$block\n```',
              ),
            ),
          ],
        ],
      ),
      actions: [
        Button(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Dismiss'),
        ),
      ],
    ),
  );
}

/// Extracts code snippets from a given assistant content.
///
/// The [assistantContent] parameter is the content provided by the assistant.
/// It searches for specific patterns using regular expressions and extracts the code snippets.
/// The extracted code snippets are returned as a list of strings.
List<String> getCodeFromMarkdown(String assistantContent) {
  List<String> codeList = [];

  final regexList = [
    shellCommandRegex,
    pythonCommandRegex,
    everythingSearchCommandRegex,
    copyToCliboardRegex,
  ];

  for (final regex in regexList) {
    final matches = regex.allMatches(assistantContent);
    for (final match in matches) {
      final command = match.group(1);
      if (command != null) {
        codeList.add(command);
      }
    }
  }
  if (codeList.isEmpty) {
    final unknownMatches = unknownCodeBlockRegex.allMatches(assistantContent);
    for (final match in unknownMatches) {
      final command = match.group(2);
      if (command != null) {
        codeList.add(command);
      }
    }
  }

  return codeList;
}

class RunCodeButton extends StatelessWidget {
  const RunCodeButton({
    super.key,
    required this.code,
    required this.language,
  });
  final String code;
  final String language;

  @override
  Widget build(BuildContext context) {
    final isSupported = language == 'shell' || language == 'python';
    if (!isSupported) {
      return const SizedBox.shrink();
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox.square(
        dimension: 30,
        child: StreamBuilder(
          stream: ShellDriver.isRunningStream,
          builder: (BuildContext ctx, AsyncSnapshot<dynamic> snap) {
            late Widget child;
            if (snap.data == true) {
              child = const Icon(FluentIcons.progress_ring_dots, size: 10);
            } else {
              child = const Icon(FluentIcons.play_solid, size: 10);
            }
            return ToggleButton(
              onChanged: (_) async {
                final provider =
                    Provider.of<ChatGPTProvider>(context, listen: false);

                if (language == 'shell') {
                  final result = await ShellDriver.runShellCommand(code);
                  provider.sendResultOfRunningShellCode(result);
                } else if (language == 'python') {
                  final result = await ShellDriver.runPythonCode(code);
                  provider.sendResultOfRunningShellCode(result);
                }
              },
              checked: snap.data == true,
              style: ToggleButtonThemeData(
                uncheckedButtonStyle: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
              ),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
