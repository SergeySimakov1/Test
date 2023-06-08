def prefilter_items(data, take_n_popular=5000):
    "функция расчета popularity, так как будем использовать неоднократно"

    def popularity_calc(data):
        popularity = data.groupby('item_id')['user_id'].nunique().reset_index()
        popularity['user_id'] = popularity['user_id'] / data['user_id'].nunique()
        popularity.rename(columns={'user_id': 'share_unique_users'}, inplace=True)

        return popularity

    # считаем popularity
    popularity = popularity_calc(data)

    # Уберем самые популярные товары (их и так купят)
    top_popular = popularity[popularity['share_unique_users'] > 0.5].item_id.tolist()
    data = data[~data['item_id'].isin(top_popular)]

    # Уберем самые НЕ популярные товары (их и так НЕ купят)
    top_notpopular = popularity[popularity['share_unique_users'] < 0.005].item_id.tolist()
    data = data[~data['item_id'].isin(top_notpopular)]

    # считаем popularity, еще раз, после того как исключили популярные и непопулярные товары
    popularity = popularity_calc(data)

    # Возьмем топ по популярности
    top_n = popularity.sort_values('share_unique_users', ascending=False).head(take_n_popular).item_id.tolist()

    # Заведем фиктивный item_id (если юзер покупал товары из топ-5000, то он "купил" такой товар)
    data.loc[~data['item_id'].isin(top_n), 'item_id'] = 999999

    # если захотим просто исключить айтемы не из топ-N
    # data = data[data['item_id'].isin(top_n)]

    return data