using FinHelper.Models.Transaction;

namespace FinHelper.Services.TransactionParser;

public interface ITransactionParserService
{
    Task<TransactionParseResult> ParseTransactionAsync(string prompt, IEnumerable<Models.Category.Category> categories);
}