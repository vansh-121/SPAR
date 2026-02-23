<?php

namespace App\Notify;

use App\Constants\Status;
use App\Models\AdminNotification;
use App\Models\NotificationLog;
use App\Models\NotificationTemplate;

class NotifyProcess {

    /*
    |--------------------------------------------------------------------------
    | Notification Process
    |--------------------------------------------------------------------------
    |
    | This is the core processor to send a notification to receiver. In this
    | class, find the notification template from database and build the final
    | message replacing the short codes and provide this to the method to send
    | the notification. Also notification log and error is creating here.
    |
     */

    /**
     * Template name, which contain the short codes and messages
     *
     * @var string
     */
    public $templateName;

    /**
     * Short Codes, which will be replaced
     *
     * @var array
     */
    public $shortCodes;

    /**
     * Instance of user, who will get the notification
     *
     * @var object
     */
    public $user;

    /**
     * Status field name in database of notification template
     *
     * @var string
     */
    protected $statusField;

    /**
     * Global template field name in database of notification method
     *
     * @var string
     */
    protected $globalTemplate;

    /**
     * Message body field name in database of notification
     *
     * @var string
     */
    protected $body;

    /**
     * Notification template instance
     *
     * @var object
     */
    public $template;

    /**
     * Message, if the email template doesn't exists
     *
     * @var string|null
     */
    public $message;

    /**
     * Notification log will be created or not
     *
     * @var bool
     */
    public $createLog;

    /**
     * Method configuration field name in database
     *
     * @var string
     */
    public $notifyConfig;

    /**
     * Subject of notification
     *
     * @var string
     */
    public $subject;

    /**
     * Name of receiver
     *
     * @var string
     */
    public $receiverName;

    /**
     * The relational field name like user_id, agent_id
     *
     * @var string
     */
    public $userColumn;

    /**
     * Address of receiver, like email, mobile number etc
     *
     * @var string
     */
    protected $toAddress;

    /**
     * Final message of notification
     *
     * @var string
     */
    protected $finalMessage;

    /**
     * Notification sent from
     *
     * @var string
     */
    protected $sentFrom = null;

    /**
     * Get the final message after replacing the short code.
     *
     * Also custom message will be return from here if notification template doesn't exist.
     *
     * @return string
     */
    protected function getMessage() {
        $this->prevConfiguration();

        $body           = $this->body;
        $user           = $this->user;
        $globalTemplate = $this->globalTemplate;

        //finding the notification template
        $template       = NotificationTemplate::where('act', $this->templateName)->where($this->statusField, Status::ENABLE)->first();
        $this->template = $template;

        if (!$this->template && $this->templateName) {
            return false;
        }

        //Getting the notification message from database if use and template exist
        //If not exist, get the message which have sent via method
        if ($user && $template) {
            $message = $this->replaceShortCode($user->fullname, $user->username, gs($globalTemplate), $template->$body);
            if (empty($message)) {
                $message = $template->$body;
            }
        } else {
            $message = $this->replaceShortCode($this->receiverName, $this->toAddress, gs($globalTemplate), $this->message);
        }

        //replace the all short code of template
        if ($this->shortCodes) {
            $message = $this->replaceTemplateShortCode($message);
        }

        //set subject to property
        $this->getSubject();

        $this->finalMessage = $message;

        //return the final message
        return $message;
    }

    /**
     * Replace the short code of global template
     *
     * @return string
     */
    protected function replaceShortCode($name, $username, $template, $body) {
        if (is_array($username)) {
            $username = implode(',', $username);
        }
        $message = str_replace("{{fullname}}", $name, $template);
        $message = str_replace("{{username}}", $username, $message);
        $message = str_replace("{{message}}", $body, $message);
        return $message;
    }

    /**
     * Replace the short code of the template
     *
     * @return string
     */
    protected function replaceTemplateShortCode($content) {
        foreach ($this->shortCodes ?? [] as $code => $value) {
            $content = str_replace('{{' . $code . '}}', $value, $content);
        }
        
        // Add CTA button if cta_url and cta_text are provided
        if (isset($this->shortCodes['cta_url']) && !empty($this->shortCodes['cta_url']) && 
            isset($this->shortCodes['cta_text']) && !empty($this->shortCodes['cta_text'])) {
            $ctaUrl = $this->shortCodes['cta_url'];
            $ctaText = $this->shortCodes['cta_text'];
            
            // CTA button HTML (email-safe styling)
            $ctaButton = '
                <tr>
                    <td align="center" style="padding: 20px 0;">
                        <table align="center" border="0" cellpadding="0" cellspacing="0">
                            <tbody>
                                <tr>
                                    <td align="center" style="background-color: #0087ff; border-radius: 6px; padding: 14px 30px;">
                                        <a href="' . htmlspecialchars($ctaUrl) . '" target="_blank" style="color: #ffffff; text-decoration: none; font-family: \'Open Sans\', Arial, sans-serif; font-size: 16px; font-weight: bold; display: inline-block;">
                                            ' . htmlspecialchars($ctaText) . '
                                        </a>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            ';
            
            // Insert CTA button after the message content
            // The message is in: <td align="left"...>...message...</td>
            // We need to insert the button row after this td, before the next row or footer
            // Pattern: Find closing </td> of message section, then insert button before next <tr> or footer
            if (preg_match('/(<td[^>]*align="left"[^>]*>.*?<\/td>\s*<\/tr>)/s', $content, $matches)) {
                // Insert button row after message row
                $content = preg_replace(
                    '/(<td[^>]*align="left"[^>]*>.*?<\/td>\s*<\/tr>)/s',
                    '$1' . $ctaButton,
                    $content,
                    1
                );
            } elseif (preg_match('/(<\/td>\s*<\/tr>\s*<tr>\s*<td height="60")/', $content)) {
                // Insert before the spacer row (height="60") if it exists
                $content = preg_replace(
                    '/(<\/td>\s*<\/tr>\s*<tr>\s*<td height="60")/',
                    $ctaButton . '$1',
                    $content,
                    1
                );
            } else {
                // Fallback: Insert before footer section
                $content = preg_replace(
                    '/(<tr>\s*<td height="45")/',
                    $ctaButton . '$1',
                    $content,
                    1
                );
            }
        }
        
        // Clean up any remaining {{cta_url}} or {{cta_text}} if not replaced (for manual templates)
        $content = str_replace('{{cta_url}}', '', $content);
        $content = str_replace('{{cta_text}}', '', $content);
        
        return $content;
    }

    /**
     * Set the subject with replaced the short codes
     *
     * @return void
     */
    protected function getSubject() {
        if ($this->template) {
            $subject = $this->template->subject;
            if ($this->shortCodes) {
                foreach ($this->shortCodes as $code => $value) {
                    $subject = str_replace('{{' . $code . '}}', $value, $subject);
                }
            }
            $this->subject = $subject;
        }
    }

    /**
     * Create the notification log
     *
     * @return void
     */
    public function createErrorLog($message) {
        $adminNotification            = new AdminNotification();
        $adminNotification->user_id   = 0;
        $adminNotification->title     = $message;
        $adminNotification->click_url = '#';
        $adminNotification->save();
    }

    /**
     * Create the error log
     *
     * @return void
     */
    public function createLog($type) {
        $userColumn = $this->userColumn;
        if ($this->user && $this->createLog) {
            $notifyConfig    = $this->notifyConfig;
            $config          = gs($notifyConfig);
            $notificationLog = new NotificationLog();
            if (@$this->user->id) {
                $notificationLog->$userColumn = $this->user->id;
            }
            $notificationLog->notification_type = $type;
            $notificationLog->sender            = @$config->name ?? 'firebase';
            $notificationLog->sent_from         = $this->sentFrom;
            $notificationLog->sent_to           = $type == 'push' ? 'Firebase Token' : $this->toAddress;
            $notificationLog->subject           = $this->subject;
            $notificationLog->image             = @$this->pushImage ?? null;
            $notificationLog->message           = $type == 'email' ? $this->finalMessage : strip_tags($this->finalMessage);
            $notificationLog->save();
        }
    }

}
