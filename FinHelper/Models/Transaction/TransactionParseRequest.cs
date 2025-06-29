using System.ComponentModel.DataAnnotations;

namespace FinHelper.Models.Transaction;

public class TransactionParseRequest
{
    [Required]
    public string Prompt { get; set; }
}