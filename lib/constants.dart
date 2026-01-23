class Constants{
 static String googleKey = "AIzaSyD0vPLizDNkVwii-uhIGer720dUilT7cL4";
 static String geminiKey  ="AIzaSyBIxvB8JqbpObPWXqX07GKewi2Eq7vLces";
 static String prompt = "Ты детектор лекарств. Найди на фото все медикаменты. " +
     "Для каждого определи: name, dosage, date, category (выбери из: Анальгетики, НПВП, Антибиотики, Витамины, Седативные и др.). " +
     "Верни ТОЛЬКО JSON массив: [{'name': '...', 'dosage': '...', 'date': '...', 'category': '...'}]. " +
     "Если данных нет, пиши пустую строку.";

 static String deepSeekKey =  "sk-e34426c9630d4a0c8f505a2a55941d36";

 static String geminiVersion = "gemini-flash-latest";
 static String geminiUrl = "$proxyUrl/v1beta/models/$geminiVersion:generateContent";

 static String proxyAddress ="https://gemini-proxy-dusky-eight.vercel.app/api/proxy";
 static String proxyUrl = "https://gemini-proxy-dusky-eight.vercel.app/api/proxy";

}