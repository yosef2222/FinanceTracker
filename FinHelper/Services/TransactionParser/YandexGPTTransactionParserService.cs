using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using FinHelper.Models.Transaction;

namespace FinHelper.Services.TransactionParser;

public class YandexGPTTransactionParserService : ITransactionParserService
{
    private readonly IConfiguration _config;
    private readonly HttpClient _httpClient;
    private const string DefaultCategory = "Прочее";

    public YandexGPTTransactionParserService(
        IConfiguration config,
        HttpClient httpClient)
    {
        _config = config;
        _httpClient = httpClient;
    }

    public async Task<TransactionParseResult> ParseTransactionAsync(
        string prompt, 
        IEnumerable<Models.Category.Category> categories)
    {
        var categoryList = categories.ToList();
        try
        {
            var categoryNames = categoryList.Select(c => c.Name).ToList();
            
            // Generate prompt for AI
            var aiPrompt = CreateParsePrompt(prompt, categoryNames);
            
            // Call YandexGPT API
            var jsonResponse = await CallYandexGPTAsync(aiPrompt);
            
            // Parse JSON response
            var result = ParseJsonResponse(jsonResponse, categoryList);
            
            return result;
        }
        catch (Exception ex)
        {
            // Fallback using categoryList which is now accessible
            var defaultCategory = categoryList.FirstOrDefault(c => c.Name == DefaultCategory) 
                                  ?? categoryList.FirstOrDefault();
            
            return new TransactionParseResult
            {
                Amount = 0,
                Merchant = "Неизвестно",
                Description = prompt,
                CategoryId = defaultCategory?.Id ?? Guid.Empty
            };
        }
    }

    private string CreateParsePrompt(string userPrompt, List<string> categoryNames)
    {
        var sb = new StringBuilder();
        
        sb.AppendLine("Ты помогаешь пользователю фиксировать транзакции. Пользователь ввел:");
        sb.AppendLine($"\"{userPrompt}\"");
        sb.AppendLine();
        sb.AppendLine("Извлеки следующие данные:");
        sb.AppendLine("- amount: сумму траты (только число)");
        sb.AppendLine("- merchant: место траты (краткое название)");
        sb.AppendLine("- description: описание траты (если не указано, используй merchant)");
        sb.AppendLine($"- category: категория траты из списка: [{string.Join(", ", categoryNames)}]");
        sb.AppendLine();
        sb.AppendLine("Верни ответ ТОЛЬКО в формате JSON:");
        sb.AppendLine("{");
        sb.AppendLine("  \"amount\": число,");
        sb.AppendLine("  \"merchant\": \"строка\",");
        sb.AppendLine("  \"description\": \"строка\",");
        sb.AppendLine("  \"category\": \"строка\"");
        sb.AppendLine("}");
        sb.AppendLine("Если категория неясна, используй 'Прочее'.");
        
        return sb.ToString();
    }

    private async Task<string> CallYandexGPTAsync(string prompt)
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
                temperature = 0.3,
                maxTokens = 1000
            },
            messages = new[]
            {
                new
                {
                    role = "system",
                    text = "Ты помогаешь пользователям фиксировать финансовые транзакции. Возвращай ответ строго в указанном JSON формате."
                },
                new
                {
                    role = "user",
                    text = prompt
                }
            }
        };

        var url = "https://llm.api.cloud.yandex.net/foundationModels/v1/completion";
        
        _httpClient.DefaultRequestHeaders.Clear();
        _httpClient.DefaultRequestHeaders.Add("x-folder-id", folderId);
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", iamToken);
        
        var response = await _httpClient.PostAsJsonAsync(url, request);
        response.EnsureSuccessStatusCode();
        
        var content = await response.Content.ReadFromJsonAsync<YandexGPTResponse>();
        return content?.Result?.Alternatives?.FirstOrDefault()?.Message?.Text ?? string.Empty;
    }

    private TransactionParseResult ParseJsonResponse(string jsonResponse, List<Models.Category.Category> categories)
    {
        // Clean JSON string (remove markdown code blocks)
        var cleanJson = Regex.Replace(jsonResponse, @"```json|```", string.Empty).Trim();
        
        // Parse JSON
        var result = JsonSerializer.Deserialize<JsonElement>(cleanJson);
        
        // Extract values
        var amount = result.GetProperty("amount").GetDecimal();
        var merchant = result.GetProperty("merchant").GetString() ?? "Неизвестно";
        var description = result.GetProperty("description").GetString() ?? merchant;
        var categoryName = result.GetProperty("category").GetString() ?? DefaultCategory;
        
        // Find category ID
        var category = categories.FirstOrDefault(c => 
            c.Name.Equals(categoryName, StringComparison.OrdinalIgnoreCase)) 
            ?? categories.FirstOrDefault(c => c.Name == DefaultCategory)
            ?? throw new Exception("Category not found");
        
        return new TransactionParseResult
        {
            Amount = amount,
            Merchant = merchant,
            Description = description,
            CategoryId = category.Id
        };
    }

    // YandexGPT Response classes
    private class YandexGPTResponse
    {
        public Result Result { get; set; }
    }

    private class Result
    {
        public List<Alternative> Alternatives { get; set; }
    }

    private class Alternative
    {
        public Message Message { get; set; }
    }

    private class Message
    {
        public string Text { get; set; }
    }

}