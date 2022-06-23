ratings = LOAD '/user/maria_dev/ml-100k/u.data' AS (userID:int, movieID:int, rating:int, ratingTime:int);
metadata = LOAD '/user/maria_dev/ml-100k/u.item' USING PigStorage('|')
	AS (movieID:int, movieTitle:chararray, releaseDate:chararray, videoRealese:chararray, imdblink:chararray);
   
nameLookup = FOREACH metadata GENERATE movieID, movieTitle;
   
groupedRatings= GROUP ratings BY movieID;

averageRatings = FOREACH groupedRatings GENERATE group as movieID, 
		AVG(ratings.rating) as avgRating,COUNT(ratings.rating) AS numRatings;

badMovies = FILTER averageRatings BY avgRating < 2.0;

namedBadMovies = JOIN badMovies BY movieID, nameLookup BY movieID;

finalResults = FOREACH namedBadMovies GENERATE nameLookup::movieTitle as movieName,
		badMovies::avgRating as avgRating, badMovies::numRatings as numRatings;

finalResultsSorted = ORDER finalResults BY numRatings DESC;

DUMP finalResultsSorted;