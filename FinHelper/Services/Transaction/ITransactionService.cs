namespace FinHelper.Models.Transaction;

public interface ITransactionService
{
    Task<TransactionResponseDto> CreateTransaction(Guid userId, TransactionDto transactionDto);
    Task<TransactionResponseDto> UpdateTransaction(Guid userId, TransactionDto transactionDto);
    Task DeleteTransaction(Guid userId, Guid transactionId);
    Task<IEnumerable<TransactionResponseDto>> GetTransactions(Guid userId, DateTime? startDate, DateTime? endDate);
    Task<TransactionResponseDto> GetTransaction(Guid userId, Guid transactionId);

}