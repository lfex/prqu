(defmodule prqu-settings
  (export all))

(defun register ()
  (let ((result (econfig:register_config
                  (prqu-const:config-name)
                  '("etc/prqu.conf" "etc/user.conf")
                  '(autoreload))))
    (case result
      ((tuple 'error (tuple 'startup_error msg))
        (tuple 'error (binary_to_list msg)))
      (_
        result))))

(defun start-config ()
  `(,(application:start 'gproc)
    ,(application:start 'econfig)))

(defun get-status ()
  (let ((`(,gproc-status ,econfig-status) (start-config))
        (register-status (register)))
    `(,gproc-status ,econfig-status ,register-status)))

(defun start ()
  (if (prqu-util:running?)
    #(skipped "Already running.")
    (let ((status (get-status)))
      (case status
        ('(ok ok ok)
          'ok)
        (_
          `#(error ,status))))))

(defun get-section (section)
  (start)
  (econfig:get_value (prqu-const:config-name) section))

(defun get-value (section key)
  (start)
  (econfig:get_value (prqu-const:config-name) section key))

(defun get-integer (section key)
  (list_to_integer (get-value section key)))

(defun get-atom (section key)
  (list_to_atom (get-value section key)))
