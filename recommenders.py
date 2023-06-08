import pandas as pd
import numpy as np

# Для работы с матрицами
from scipy.sparse import csr_matrix

# Матричная факторизация
from implicit.als import AlternatingLeastSquares
from implicit.nearest_neighbours import ItemItemRecommender
from implicit.nearest_neighbours import bm25_weight, tfidf_weight


class MainRecommender:

    def __init__(self, data):

        self.user_item_matrix = self.prepare_matrix(data)
        self.id_to_itemid, self.id_to_userid, self.itemid_to_id, self.userid_to_id = self.prepare_dicts(
            self.user_item_matrix)

        self.als_recommender = self.fit_als_recommender(self.user_item_matrix)
        self.own_recommender = self.fit_own_recommender(self.user_item_matrix)

        self.sparse_user_item = csr_matrix(self.user_item_matrix).tocsr()

        self.popularity = data[data['item_id'] != 999999]. \
            groupby('item_id').count().reset_index().sort_values('user_id', ascending=False)

    @staticmethod
    def prepare_matrix(data):

        user_item_matrix = pd.pivot_table(data,
                                          index='user_id', columns='item_id',
                                          values='quantity',  # Можно пробовать другие варианты
                                          aggfunc='count',
                                          fill_value=0
                                          )

        user_item_matrix = user_item_matrix.astype(float)  # необходимый тип матрицы для implicit

        return user_item_matrix

    @staticmethod
    def prepare_dicts(user_item_matrix):
        """Подготавливает вспомогательные словари"""

        userids = user_item_matrix.index.values
        itemids = user_item_matrix.columns.values

        matrix_userids = np.arange(len(userids))
        matrix_itemids = np.arange(len(itemids))

        id_to_itemid = dict(zip(matrix_itemids, itemids))
        id_to_userid = dict(zip(matrix_userids, userids))

        itemid_to_id = dict(zip(itemids, matrix_itemids))
        userid_to_id = dict(zip(userids, matrix_userids))

        return id_to_itemid, id_to_userid, itemid_to_id, userid_to_id

    @staticmethod
    def fit_own_recommender(user_item_matrix):
        """Обучает модель, которая рекомендует товары, среди товаров, купленных юзером"""

        own_recommender = ItemItemRecommender(K=5, num_threads=4)
        own_recommender.fit(csr_matrix(user_item_matrix).tocsr())

        return own_recommender

    @staticmethod
    def fit_als_recommender(user_item_matrix, n_factors=20, regularization=0.001, iterations=15, num_threads=4):
        """Обучает ALS"""

        als_recommender = AlternatingLeastSquares(factors=n_factors,
                                                  regularization=regularization,
                                                  iterations=iterations,
                                                  num_threads=num_threads)
        als_recommender.fit(csr_matrix(user_item_matrix).tocsr())

        return als_recommender

    def _get_recommendations(self, user, model, N=5):
        """Функция получения рекоммендаций"""

        # если нет пользователя с таким id, то возвращается топ N айтемов
        if user not in self.user_item_matrix.index:
            return self.popularity['item_id'][:N].tolist()

        res = [self.id_to_itemid[rec] for rec in
               model.recommend(userid=self.userid_to_id[user],
                               user_items=self.sparse_user_item[self.userid_to_id[user]],  # на вход user-item matrix
                               N=N,
                               filter_already_liked_items=False,
                               filter_items=[self.itemid_to_id[999999]],
                               recalculate_user=False)[0]]

        # если кол-во рекомендаций меньше заданного, то возвращается топ N айтемов
        if len(res) < N:
            res = self.popularity['item_id'][:N].tolist()

        return res

    """Рекомендации через стардартные библиотеки implicit"""

    def get_own_recommendations(self, user, N=5):
        "item-item рекоммендор"

        return self._get_recommendations(user, model=self.own_recommender, N=N)

    def get_als_recommendations(self, user, N=5):
        "als рекоммендор"

        return self._get_recommendations(user, model=self.als_recommender, N=N)