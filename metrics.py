import numpy as np
import pandas as pd

def precision_at_k(recommended_list, bought_list, k=5):
    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)

    bought_list = bought_list  # Тут нет [:k] !!
    recommended_list = recommended_list[:k]

    flags = np.isin(recommended_list, bought_list)

    precision = flags.sum() / len(recommended_list)

    return precision


def recall_at_k(recommended_list, bought_list, k=5):
    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)

    bought_list = bought_list  # Тут нет [:k] !!
    recommended_list = recommended_list[:k]

    flags = np.isin(recommended_list, bought_list)

    recall = flags.sum() / len(bought_list)

    return recall


def money_precision_at_k(recommended_list, bought_list, prices_recommended, k=5):
    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)
    prices_recommended = np.array(prices_recommended)

    bought_list = bought_list  # Тут нет [:k] !!
    recommended_list = recommended_list[:k]
    prices_recommended = prices_recommended[:k]

    flags = np.isin(recommended_list, bought_list)

    precision = (flags * prices_recommended).sum() / prices_recommended.sum()

    return precision


def money_recall_at_k(recommended_list, bought_list, prices_recommended, prices_bought, k=5):
    # your_code

    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)
    prices_recommended = np.array(prices_recommended)
    prices_bought = np.array(prices_bought)

    bought_list = bought_list  # Тут нет [:k] !!
    recommended_list = recommended_list[:k]
    prices_recommended = prices_recommended[:k]
    prices_bought = prices_bought[:k]

    flags = np.isin(recommended_list, bought_list)

    recall = (flags * prices_recommended).sum() / prices_bought.sum()

    return recall



def mrr_at_k(recommended_list, bought_list, k=5):
    # your_code

    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)

    recommended_list = recommended_list[:k]
    flags = np.isin(recommended_list, bought_list)

    # порядковый номер первого релевантного элемента и + 1, так как нумерация начинается с 0.
    try:
        rank = np.where(flags == True)[0][0] + 1
        reciprocal_rank = 1 / rank
        # обработаем ошибку отсутствия релевантных значений в k первых рекомендованных
    except Exception:
        reciprocal_rank = 0

    return reciprocal_rank

def hit_rate_at_k(recommended_list, bought_list, k=5):
    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)

    flags = np.isin(recommended_list[:k], bought_list)
    hit_rate = int(flags.sum() > 0)

    return hit_rate


def ap_k(recommended_list, bought_list, k=5):
    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)

    flags = np.isin(recommended_list, bought_list)

    if sum(flags) == 0:
        return 0

    sum_ = 0
    for i in range(k):

        if flags[i]:
            p_k = precision_at_k(recommended_list, bought_list, k=i + 1)
            sum_ += p_k

    result = sum_ / k

    return result


def ndcg_at_k(recommended_list, bought_list, k=5):
    bought_list = np.array(bought_list)
    recommended_list = np.array(recommended_list)

    recommended_list = recommended_list[:k]
    flags = np.isin(recommended_list, bought_list)

    # в формуле в числителе hit rate, а в знаменателе логарифм от ранка
    hit_rate = int(flags.sum() > 0)
    rank = np.where(flags == True)[0][0] + 1

    ndsg = hit_rate / np.log2(rank + 1)

    return ndsg
