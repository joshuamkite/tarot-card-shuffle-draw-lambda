// API service for interacting with the tarot draw backend

const getApiUrl = () => {
    // In production, use the environment variable
    // In development, use empty string to leverage Vite proxy
    return import.meta.env.VITE_API_URL || '';
};

export const drawCards = async (deckSize, deckReverse, numCards) => {
    const apiUrl = getApiUrl();

    try {
        const response = await fetch(`${apiUrl}/draw`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                deckSize,
                deckReverse,
                numCards,
            }),
        });

        if (!response.ok) {
            const errorData = await response.json().catch(() => ({}));
            throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
        }

        return await response.json();
    } catch (error) {
        console.error('Error drawing cards:', error);
        throw error;
    }
};