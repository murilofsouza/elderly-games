# 🃏 Jogo da Memória — Especificação Completa

## Resumo
Jogo clássico de encontrar pares de cartas. Progressão sequencial por fases, começando fácil e aumentando gradualmente. Cartas usam **fotos reais** de frutas e animais.

---

## Progressão de Fases

O jogo tem fases sequenciais. O jogador precisa completar uma fase para desbloquear a próxima.

| Fase | Pares | Grid    | Tema   | Tempo Limite | Multiplicador |
|------|-------|---------|--------|--------------|---------------|
| 1    | 4     | 2×4     | Frutas | Sem limite   | 1.0x          |
| 2    | 5     | 2×5     | Frutas | Sem limite   | 1.0x          |
| 3    | 6     | 3×4     | Frutas | Sem limite   | 1.2x          |
| 4    | 6     | 3×4     | Animais| 3 minutos    | 1.2x          |
| 5    | 8     | 4×4     | Animais| 3 minutos    | 1.5x          |
| 6    | 8     | 4×4     | Misto  | 2.5 minutos  | 1.5x          |
| 7    | 10    | 4×5     | Misto  | 2.5 minutos  | 1.8x          |
| 8    | 12    | 4×6     | Misto  | 2 minutos    | 2.0x          |

> As fases 1-3 não têm tempo limite para o idoso se acostumar sem pressão.
> O timer só aparece a partir da fase 4, e é generoso.

Após completar todas as 8 fases, o jogador pode rejogá-las para bater recordes.

---

## Mecânica do Jogo

### Fluxo de uma rodada
1. Jogador entra no jogo → vê a fase atual (ex: "Fase 3 — Frutas")
2. Toca em "Jogar" → cartas aparecem viradas para baixo
3. **Preview**: todas as cartas ficam viradas por **3 segundos** para o jogador memorizar (apenas nas fases 1-3)
4. Cartas viram para baixo → jogo começa
5. Jogador toca em uma carta → ela vira (animação 0.4s)
6. Jogador toca em uma segunda carta → ela vira
7. **Se par**: cartas brilham verde, ficam viradas, som de acerto, "+2 pts" flutua
8. **Se não par**: cartas balançam suave, som leve (não punitivo), viram de volta após 1.2s
9. Repete até encontrar todos os pares
10. Tela de resultado com pontuação

### Regras importantes
- Apenas **2 cartas** viradas por vez
- A primeira carta fica virada até o jogador escolher a segunda (sem timer entre elas)
- Cartas já encontradas ficam viradas e levemente transparentes
- O jogador pode tocar na mesma carta virada para desvirá-la (desfazer)

---

## Sistema de Pontuação

### Ganhos por partida

| Ação                        | Pontos Base | Observação                            |
|-----------------------------|-------------|---------------------------------------|
| Par encontrado              | +2          | Por cada par                          |
| Combo (2 pares seguidos)    | +1 bônus    | Acertou sem errar entre eles          |
| Combo (3+ pares seguidos)   | +2 bônus    | Por par adicional no combo            |
| Completar fase              | +5          | Bônus fixo por conclusão              |
| Completar sem erro          | +10         | Bônus "Memória Perfeita"              |
| Completar no tempo recorde  | +3          | Se bater o melhor tempo pessoal       |

> Todos os pontos são multiplicados pelo multiplicador da fase.
> Exemplo: Fase 5 (1.5x) → par encontrado = +3 pontos

### Streak diário (já definido no sistema global)
| Dias consecutivos | Bônus extra |
|--------------------|-------------|
| 3 dias             | +10         |
| 7 dias             | +20         |
| 14 dias            | +30         |
| 30 dias            | +50         |

---

## Dica (5 pontos)

### O que acontece:
1. Jogador toca no botão "Dica" na barra inferior
2. **Uma carta** pisca com borda dourada por 1.5 segundos
3. Depois, a **carta par** dela pisca por mais 1.5 segundos
4. Ambas voltam ao normal

### Regras:
- Máximo **3 dicas por partida**
- Mostra sempre um par que **ainda não foi encontrado**
- Prioriza pares que o jogador já errou (se houver tracking)
- O contador de dicas restantes aparece no botão: "Dica (2 restantes)"

---

## Pular (15 pontos)

### O que acontece:
1. Jogador toca no botão "Pular"
2. Um par é revelado automaticamente com animação de flip
3. As cartas ficam viradas (marcadas como encontradas)
4. O jogador **não ganha pontos** por esse par

### Regras:
- Máximo **1 pular por partida**
- Não conta como erro nem quebra combo
- Útil quando o jogador está frustrado ou travado

---

## Visual e Acessibilidade

### Cartas
- **Tamanho mínimo**: 70×70 dp por carta
- **Foto real** da fruta/animal centralizada
- **Nome escrito embaixo** da foto (ex: "Maçã", "Gato") — ajuda idosos com visão reduzida
- **Verso da carta**: cor sólida com padrão sutil (ex: verde escuro com textura leve)
- **Borda arredondada**: 12dp
- **Espaço entre cartas**: 8dp mínimo (evita toque errado)

### Fotos reais necessárias (v1)

**Tema Frutas (8 fotos):**
- 🍎 Maçã
- 🍌 Banana
- 🍇 Uva
- 🍊 Laranja
- 🍓 Morango
- 🍉 Melancia
- 🍍 Abacaxi
- 🍑 Pêssego

**Tema Animais (8 fotos):**
- 🐱 Gato
- 🐶 Cachorro
- 🐦 Pássaro
- 🐟 Peixe
- 🐴 Cavalo
- 🐰 Coelho
- 🐢 Tartaruga
- 🦋 Borboleta

> As fotos devem ser nítidas, com fundo limpo/branco, alta resolução.
> Formato: PNG, 512×512px mínimo.
> O designer (você) fornece essas imagens.

### Animações
| Ação          | Animação                   | Duração |
|---------------|----------------------------|---------|
| Virar carta   | Flip 3D horizontal         | 0.4s    |
| Par encontrado| Brilho verde + scale up    | 0.3s    |
| Par errado    | Shake leve horizontal      | 0.3s    |
| Pontos ganhos | Texto "+2" flutua pra cima | 0.8s    |
| Combo         | Estrelinhas ao redor       | 0.5s    |
| Dica          | Borda dourada pulsante     | 1.5s    |
| Completou     | Confetti / fogos           | 1.5s    |

### Sons
| Evento        | Som                                    |
|---------------|----------------------------------------|
| Toque carta   | "Tap" suave                            |
| Acertou par   | Sino alegre curto                      |
| Errou par     | "Whomp" suave (NÃO buzina de erro)     |
| Combo         | Cascata de sinos                       |
| Usou dica     | "Ding" informativo                     |
| Completou fase| Fanfarra curta e alegre                |
| Tempo acabando| Tic-tac suave (últimos 30s)            |

---

## Telas do Jogo

### 1. Tela de Seleção de Fase
```
┌─────────────────────────────┐
│  ← Voltar    JOGO DA MEMÓRIA│
│                              │
│  ★ 234 pontos disponíveis    │
│                              │
│  ┌─────────┐  ┌─────────┐   │
│  │ FASE 1  │  │ FASE 2  │   │
│  │ 🍎 Frutas│  │ 🍎 Frutas│   │
│  │ 4 pares │  │ 5 pares │   │
│  │ ★★★     │  │ ★★☆     │   │
│  └─────────┘  └─────────┘   │
│  ┌─────────┐  ┌─────────┐   │
│  │ FASE 3  │  │ 🔒 FASE 4│   │
│  │ 🍎 Frutas│  │ 🐱 Animais│  │
│  │ 6 pares │  │ 6 pares │   │
│  │ ☆☆☆     │  │ bloqueado│   │
│  └─────────┘  └─────────┘   │
│                              │
│  ★★★ = perfeito (sem erros)  │
│  ★★☆ = bom                   │
│  ★☆☆ = completou             │
└─────────────────────────────┘
```
- Fases bloqueadas aparecem com cadeado
- Estrelas mostram melhor desempenho anterior (0 a 3)
- 3 estrelas = completou sem erros

### 2. Tela de Jogo (durante a partida)
```
┌─────────────────────────────┐
│  ← Sair   Fase 3   ⏱ 2:45   │
│                              │
│  Pares: 2/6      Combo: x2  │
│                              │
│  ┌────┐ ┌────┐ ┌────┐       │
│  │ 🍎 │ │ ?? │ │ ?? │       │
│  │Maçã│ │    │ │    │       │
│  └────┘ └────┘ └────┘       │
│  ┌────┐ ┌────┐ ┌────┐       │
│  │ ?? │ │ 🍎 │ │ ?? │       │
│  │    │ │Maçã│ │    │       │
│  └────┘ └────┘ └────┘       │
│  ┌────┐ ┌────┐ ┌────┐       │
│  │ ?? │ │ ?? │ │ ?? │       │
│  │    │ │    │ │    │       │
│  └────┘ └────┘ └────┘       │
│  ┌────┐ ┌────┐ ┌────┐       │
│  │ ?? │ │ ?? │ │ ?? │       │
│  │    │ │    │ │    │       │
│  └────┘ └────┘ └────┘       │
│                              │
│ ★234 │ 💡Dica(3) │ ⏭Pular(1)│
└─────────────────────────────┘
```

### 3. Tela de Resultado
```
┌─────────────────────────────┐
│                              │
│        🎉 Parabéns! 🎉       │
│                              │
│     Fase 3 — Completa!       │
│          ★ ★ ★               │
│                              │
│  Pares encontrados:  6/6     │
│  Erros:              2       │
│  Tempo:              1:32    │
│  Combo máximo:       x3      │
│                              │
│  ─────────────────────────   │
│  Pontos dos pares:    +14    │
│  Bônus de combo:      +4     │
│  Bônus conclusão:     +5     │
│  Bônus streak (7d):   +20    │
│  ─────────────────────────   │
│  TOTAL GANHO:         +43 ★  │
│                              │
│  ┌─────────────────────────┐ │
│  │    PRÓXIMA FASE →       │ │
│  └─────────────────────────┘ │
│                              │
│     Jogar de Novo  │  Voltar │
└─────────────────────────────┘
```

---

## Dados a Persistir

```dart
// Progresso do Jogo da Memória
class MemoryGameProgress {
  int currentPhase;           // fase mais alta desbloqueada (1-8)
  Map<int, PhaseResult> best; // melhor resultado por fase
}

class PhaseResult {
  int stars;        // 0-3
  int bestTime;     // em segundos
  int bestScore;    // pontuação da partida
  int errors;       // menor número de erros
  DateTime playedAt;
}
```

---

## Observações para o Designer

1. **Fotos das cartas**: você fornece 16 fotos (8 frutas + 8 animais) em PNG 512×512 com fundo branco/limpo
2. **Verso da carta**: precisa de um design para o verso (pode ser a logo do app ou um padrão)
3. **Ícone do jogo**: ícone que aparece na home (card de seleção)
4. **Tela de resultado**: considere uma ilustração/animação de celebração
5. **Estrelas**: ícone de estrela cheia e vazia para o rating de fase
6. **Cores**: cartas encontradas ficam com overlay verde semi-transparente

---

## Checklist de Implementação

- [ ] Modelo de dados (MemoryGameProgress, PhaseResult)
- [ ] Tela de seleção de fases com grid
- [ ] Lógica do jogo (flip, match, combo tracking)
- [ ] Grid responsivo que se adapta ao tamanho de tela
- [ ] Animação de flip 3D
- [ ] Animação de acerto/erro
- [ ] Sistema de timer (fases 4+)
- [ ] Integração com PointsManager (ganhar/gastar)
- [ ] Lógica de dica (revelar par)
- [ ] Lógica de pular (auto-completar par)
- [ ] Tela de resultado com breakdown de pontos
- [ ] Persistência de progresso por fase
- [ ] Preview inicial (fases 1-3)
- [ ] Sons de feedback
- [ ] Estrelas por desempenho
- [ ] Assets placeholder até ter as fotos reais