using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models;

public class UserDto
{
    [Required(ErrorMessage = "Full name is required.")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Full name must be between 3 and 50 characters.")]
    public string FullName { get; set; }

    [Required(ErrorMessage = "Birth date is required.")]
    [BirthDateValidation] 
    public DateTime Birthday { get; set; }

    [Required(ErrorMessage = "Email is required.")]
    [EmailAddress(ErrorMessage = "Invalid email address.")]
    public string Email { get; set; }

    [Required(ErrorMessage = "Password is required.")]
    [StringLength(100, MinimumLength = 6, ErrorMessage = "Password must be at least 6 characters long.")]
    [PasswordValidation] 
    public string Password { get; set; }
    
}