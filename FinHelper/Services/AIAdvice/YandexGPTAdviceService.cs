using System.Net.Http.Headers;
using System.Text;
using FinHelper.Models.Budget;
using FinHelper.Models.Transaction;

namespace FinHelper.Services.AIAdvice;

public class YandexGPTAdviceService : IAIAdviceService
{
    private readonly IConfiguration _config;
    private readonly ITransactionService _transactionService;
    private readonly IBudgetService _budgetService;
    private readonly HttpClient _httpClient;

    public YandexGPTAdviceService(
        IConfiguration config,
        ITransactionService transactionService,
        IBudgetService budgetService,
        HttpClient httpClient)
    {
        _config = config;
        _transactionService = transactionService;
        _budgetService = budgetService;
        _httpClient = httpClient;
    }

    public async Task<string?> GenerateFinancialAdviceAsync(Guid userId)
    {
        try
        {
            // Get financial data
            var transactions = await _transactionService.GetTransactions(userId, DateTime.UtcNow.AddMonths(-3), DateTime.UtcNow);
            var budgets = await _budgetService.GetBudgets(userId);

            // Prepare financial summary
            var summary = PrepareFinancialSummary(transactions, budgets);
            
            // Generate prompt
            var prompt = CreatePrompt(summary);
            
            // Call YandexGPT API
            return await CallYandexGPTAsync(prompt);
        }
        catch (Exception ex)
        {
            return $"Не удалось сгенерировать персонализированный совет. Общий совет: Анализируйте свои расходы регулярно и корректируйте бюджеты. Ошибка: {ex.Message}";
        }
    }

    private FinancialSummary PrepareFinancialSummary(IEnumerable<TransactionResponseDto> transactions, 
                                                    IEnumerable<BudgetResponseDto> budgets)
    {
        var summary = new FinancialSummary();
        
        // Calculate spending by category
        summary.CategorySpending = transactions
            .GroupBy(t => t.Category.Name)
            .Select(g => new CategorySpending
            {
                Category = g.Key,
                TotalSpent = g.Sum(t => t.Amount)
            })
            .ToList();
        
        // Budget vs actual
        summary.BudgetAnalysis = budgets.Select(b => new BudgetAnalysis
        {
            Category = b.Category.Name,
            BudgetAmount = b.Amount,
            ActualSpending = b.CurrentSpending,
            PercentageUsed = b.CurrentSpending / b.Amount * 100
        }).ToList();
        
        // Total spending
        summary.TotalSpendingLastMonth = transactions
            .Where(t => t.Date >= DateTime.UtcNow.AddMonths(-1))
            .Sum(t => t.Amount);
        
        summary.TotalSpendingLast3Months = transactions.Sum(t => t.Amount);
        
        return summary;
    }

    private string CreatePrompt(FinancialSummary summary)
    {
        var sb = new StringBuilder();
        
        sb.AppendLine("Ты финансовый консультант. Проанализируй следующие данные пользователя и дай персональные рекомендации на русском языке:");
        sb.AppendLine();
        
        sb.AppendLine("### Расходы по категориям за последние 3 месяца:");
        foreach (var category in summary.CategorySpending)
        {
            sb.AppendLine($"- {category.Category}: {category.TotalSpent} руб.");
        }
        sb.AppendLine();
        
        sb.AppendLine("### Соответствие бюджетам:");
        foreach (var budget in summary.BudgetAnalysis)
        {
            var status = budget.PercentageUsed > 100 ? "ПРЕВЫШЕН" : 
                         budget.PercentageUsed > 80 ? "ПРИБЛИЖАЕТСЯ К ЛИМИТУ" : "В ПРЕДЕЛАХ";
            
            sb.AppendLine($"- {budget.Category}: " +
                          $"Бюджет: {budget.BudgetAmount} руб., " +
                          $"Факт: {budget.ActualSpending} руб. ({budget.PercentageUsed:F0}%), " +
                          $"Статус: {status}");
        }
        sb.AppendLine();
        
        sb.AppendLine($"Общие расходы за последний месяц: {summary.TotalSpendingLastMonth} руб.");
        sb.AppendLine($"Общие расходы за 3 месяца: {summary.TotalSpendingLast3Months} руб.");
        sb.AppendLine();
        
        sb.AppendLine("### Запрос:");
        sb.AppendLine("Проанализируй финансовое поведение пользователя и дай практические рекомендации:");
        sb.AppendLine("1. В каких категориях можно сократить расходы");
        sb.AppendLine("2. Как оптимизировать текущие бюджеты");
        sb.AppendLine("3. Советы по увеличению сбережений");
        sb.AppendLine("4. Общий анализ финансового здоровья");
        sb.AppendLine("Отвечай на русском языке, будь конкретен и используй дружелюбный, мотивирующий тон.");
        
        return sb.ToString();
    }

    private async Task<string?> CallYandexGPTAsync(string prompt)
    {
        var folderId = _config["YandexGPT:FolderId"];
        var iamToken = _config["YandexGPT:IamToken"];
        var model = _config["YandexGPT:Model"] ?? "yandexgpt-lite";
        
        var request = new
        {
            modelUri = $"gpt://{folderId}/{model}/latest",
            completionOptions = new
            {
                stream = false,
                temperature = 0.6,  // Adjusted for more creative responses
                maxTokens = 2000
            },
            messages = new[]
            {
                new
                {
                    role = "system",
                    text = "Ты финансовый консультант, который дает персональные советы по оптимизации расходов и бюджетов."
                },
                new
                {
                    role = "user",
                    text = prompt
                }
            }
        };

        var url = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion";
        
        // Set headers as required by Yandex GPT
        _httpClient.DefaultRequestHeaders.Clear();
        _httpClient.DefaultRequestHeaders.Add("x-folder-id", folderId);
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", iamToken);
        
        var response = await _httpClient.PostAsJsonAsync(url, request);
        response.EnsureSuccessStatusCode();
        
        var content = await response.Content.ReadFromJsonAsync<YandexGPTResponse>();
        return content?.Result?.Alternatives?.FirstOrDefault()?.Message?.Text ?? "Не удалось получить совет";
    }

    // Helper classes
    private class FinancialSummary
    {
        public List<CategorySpending> CategorySpending { get; set; }
        public List<BudgetAnalysis> BudgetAnalysis { get; set; }
        public decimal TotalSpendingLastMonth { get; set; }
        public decimal TotalSpendingLast3Months { get; set; }
    }

    private class CategorySpending
    {
        public string Category { get; set; }
        public decimal TotalSpent { get; set; }
    }

    private class BudgetAnalysis
    {
        public string Category { get; set; }
        public decimal BudgetAmount { get; set; }
        public decimal ActualSpending { get; set; }
        public decimal PercentageUsed { get; set; }
    }

    private class YandexGPTResponse
    {
        public Result Result { get; set; }
    }

    private class Result
    {
        public List<Alternative> Alternatives { get; set; }
        public Usage Usage { get; set; }
    }

    private class Alternative
    {
        public Message Message { get; set; }
        public string Status { get; set; }
    }

    private class Message
    {
        public string Role { get; set; }
        public string? Text { get; set; }
    }

    private class Usage
    {
        public string InputTextTokens { get; set; }
        public string CompletionTokens { get; set; }
        public string TotalTokens { get; set; }
    }
}