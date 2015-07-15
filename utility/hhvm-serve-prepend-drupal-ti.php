<?php

// HHVM Serve compatibility script.
// Loosely based on https://github.com/drush-ops/drush/blob/master/commands/runserver/runserver-prepend.php

if (!isset($_GET['q']) && isset($_SERVER['PATH_INFO'])) {
  $request_path = $_SERVER['PATH_INFO'];
  $base_path_len = strlen(rtrim(dirname($_SERVER['SCRIPT_NAME']), '\/'));
  // Unescape and strip $base_path prefix, leaving q without a leading slash.
  $_GET['q'] = substr(urldecode($request_path), $base_path_len + 1);

  // Set REQUEST_URI.
  $_SERVER['REQUEST_URI'] = $_SERVER['PATH_INFO'];
  if (!empty($_SERVER['QUERY_STRING'])) {
    $_SERVER['REQUEST_URI'] .= '?' . $_SERVER['QUERY_STRING'];
  }
}

// We hijack system_watchdog (which core system module does not implement) as
// a convenient place to capture logs.
if (!function_exists('system_watchdog')) {
  // Check function_exists as a safety net in case it is added in future.
  function system_watchdog($log_entry = array()) {
    // Drupal <= 7.x defines VERSION. Drupal 8 defines Drupal::VERSION instead.
    if (defined('VERSION')) {
      $uid = $log_entry['user']->uid;
    }
    else {
      $uid = $log_entry['user']->id();
    }
    $message = strtr('Watchdog: !message | severity: !severity | type: !type | uid: !uid | !ip | !request_uri | !referer | !link', array(
      '!message'     => strip_tags(!isset($log_entry['variables']) ? $log_entry['message'] : strtr($log_entry['message'], $log_entry['variables'])),
      '!severity'    => $log_entry['severity'],
      '!type'        => $log_entry['type'],
      '!ip'          => $log_entry['ip'],
      '!request_uri' => $log_entry['request_uri'],
      '!referer'     => $log_entry['referer'],
      '!uid'         => $uid,
      '!link'        => strip_tags($log_entry['link']),
    ));
    error_log($message);
  }
}
