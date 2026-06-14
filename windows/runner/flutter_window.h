#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/encodable_value.h>
#include <flutter/flutter_view_controller.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <memory>
#include <string>

#include "win32_window.h"

// A window that does nothing but host a Flutter view.
class FlutterWindow : public Win32Window {
 public:
  // Creates a new FlutterWindow hosting a Flutter view running |project|.
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window:
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND window, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;

 private:
  // The project to run.
  flutter::DartProject project_;

  // The Flutter instance hosted by this window.
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
  
  // Method channel for forwarding power events to Dart via window_manager channel.
  std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>> power_event_channel_;

  // Setup app method channel
  void SetupAppMethodChannel();

  // Send a power event to Dart layer.
  void SendPowerEvent(const std::string& event_name);
  
  // Set window icon
  bool SetWindowIcon(bool use_light_icon);

  // Save icon preference
  void SaveIconPreference(bool use_light_icon);
  
  // Load icon preference
  bool LoadIconPreference();
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
