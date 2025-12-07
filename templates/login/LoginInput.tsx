import * as React from "react"

export type LoginInputProps = React.InputHTMLAttributes<HTMLInputElement> & {
  label: string
  error?: string
  helperText?: string
}

export const LoginInput = React.forwardRef<HTMLInputElement, LoginInputProps>(
  ({ label, error, helperText, id, className, ...props }, ref) => {
    const inputId = id || React.useId()

    return (
      <div className="so-input-group">
        <label className="so-input-label" htmlFor={inputId}>
          {label}
        </label>
        <input
          ref={ref}
          id={inputId}
          className={["so-input-control", error ? "error" : "", className].filter(Boolean).join(" ")}
          aria-invalid={Boolean(error)}
          aria-describedby={error ? `${inputId}-error` : helperText ? `${inputId}-helper` : undefined}
          {...props}
        />
        {error ? (
          <span id={`${inputId}-error`} className="so-input-error">
            {error}
          </span>
        ) : helperText ? (
          <span id={`${inputId}-helper`} className="so-input-helper">
            {helperText}
          </span>
        ) : null}
      </div>
    )
  }
)
LoginInput.displayName = "LoginInput"
